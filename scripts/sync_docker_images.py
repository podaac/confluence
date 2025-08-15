#!/usr/bin/env python3
import subprocess
import urllib
import json
from os import getenv
import re
from urllib import request
import sys
from pathlib import Path
import urllib.error
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

docker_image_re = re.compile(
    r'^(?:(?P<server>[^/]+(?:\.[^/]+)+(?:[:][0-9]+)?)/)?(?P<image>[^:]+)(?::(?P<tag>[^@]+))?$'
)
manifest_v2_endpoint = 'https://{server}/v2/{image}/manifests/{tag}'


def main():
    logging.info('Fetching Terraform output...')
    returncode, stdout, stderr = run_cmd('terraform output --json', cwd=Path(__file__).joinpath('../../terraform').resolve())
    if returncode != 0:
        logging.error(f'Error running terraform output: {stderr.decode('utf-8')}')
        sys.exit(1)
        
    terraform_output = json.loads(stdout.decode('utf-8'))
    images = terraform_output['docker_images']['value']
    source_docker_registry = terraform_output['source_docker_registry']['value']
    destination_docker_registry = terraform_output['destination_docker_registry']['value']

    logging.info(f'Loading source auth token: {source_docker_registry}')
    source_auth_token = load_docker_auth(source_docker_registry)
    logging.info(f'Loading destination auth token: {destination_docker_registry}')
    destination_auth_token = load_docker_auth(destination_docker_registry)

    sync_needed = []

    for image in images.values():
        source = docker_image_re.match(image['source_name']).groupdict()
        destination = docker_image_re.match(image['destination_name']).groupdict()

        logging.debug(f'Source: {source}')
        logging.debug(f'Manifest URL: {manifest_v2_endpoint.format(**source)}')
        source_req = request.Request(
            manifest_v2_endpoint.format(**source),
            headers={
                'Accept': 'application/vnd.docker.distribution.manifest.v2+json',
                'Authorization': f'Bearer {source_auth_token}'
            }
        )

        try:
            source_res = request.urlopen(source_req)
        except urllib.error.HTTPError as ex:
            if ex.code == 404:
                logging.error('Source image not found; check config')

            raise ex

        source_manifest = json.loads(str(source_res.read(), 'utf-8'))
        source_hash = source_manifest['config']['digest']

        logging.debug(f'Destination: {destination}')
        logging.debug(f'Manifest URL: {manifest_v2_endpoint.format(**destination)}')
        dest_req = request.Request(
            manifest_v2_endpoint.format(**destination),
            headers={
                'Accept': 'application/vnd.docker.distribution.manifest.v2+json',
                'Authorization': f'Basic {destination_auth_token}'
            }
        )

        try:
            dest_res = request.urlopen(dest_req)
        except urllib.error.HTTPError as ex:
            if ex.code == 404:  # Image not found; needs a sync
                logging.info(f'Sync needed due to image not found: {image['destination_name']}')
                sync_needed.append(image)
                continue
            else:
                raise ex

        dest_manifest = json.loads(str(dest_res.read(), 'utf-8'))
        dest_hash = dest_manifest['config']['digest']

        if source_hash != dest_hash:
            logging.info(f'Sync needed due to hash mismatch for image: {image['source_name']} -> {image['destination_name']}')
            sync_needed.append(image)
            continue

        logging.info(f'Sync not needed for image: {image['source_name']} -> {image['destination_name']}')
        
    logging.debug(f'Creating scans directory')
    scans_dir = Path.cwd().joinpath('..', 'scans')
    scans_dir.mkdir(exist_ok=True)

    for image in sync_needed:
        logging.info(f'Syncing image: {image['source_name']} -> {image['destination_name']}')
        # Trigger the sync process here
        run_cmd(f'docker pull {image['source_name']}', stdout=sys.stdout, stderr=sys.stderr)

        # Scan container image with Trivy
        sarif_file = scans_dir.joinpath(f'{image['destination_repository']}.sarif')
        run_cmd(f'trivy image --severity HIGH,CRITICAL --format sarif --output {sarif_file} {image['source_name']}', stdout=sys.stdout, stderr=sys.stderr)
        add_category_to_scan(sarif_file, image['destination_repository'])

        # Tag and push the image to the destination registry
        run_cmd(f'docker tag {image['source_name']} {image['destination_name']}', stdout=sys.stdout, stderr=sys.stderr)
        run_cmd(f'docker push {image['destination_name']}', stdout=sys.stdout, stderr=sys.stderr)
        run_cmd(f'docker rmi {image['source_name']} {image['destination_name']}', stdout=sys.stdout, stderr=sys.stderr)

    Path(getenv('GITHUB_OUTPUT')).write_text(f'synced_images={bool(sync_needed)}\n')


def load_docker_auth(server):
    config = json.load(Path('~/.docker/config.json').expanduser().open('r'))
    return config['auths'][server]['auth']


def run_cmd(cmd: str, cwd=None, stdout=None, stderr=None):
    if stdout is None:
        stdout = subprocess.PIPE
    if stderr is None:
        stderr = subprocess.PIPE
    process = subprocess.Popen(cmd, shell=True, stdout=stdout, stderr=stderr, cwd=cwd)
    stdout, stderr = process.communicate()
    return process.returncode, stdout, stderr


def add_category_to_scan(scan_file: Path, category: str):
    with scan_file.open('r+') as f:
        data = json.load(f)
        data['runAutomationDetails'] = {
            'id': category
        }
        f.seek(0)
        json.dump(data, f, indent=2)
        f.truncate()


if __name__ == '__main__':
    main()
