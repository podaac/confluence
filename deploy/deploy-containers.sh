#!/bin/bash
#
# Script to deploy a container image to an AWS ECR.
#
# Command line arguments:
# [1] registry: Registry URI
# [2] prefix: Venue deployment prefix
# 
# Example usage: ./delpoy-ecr.sh "account-id.dkr.ecr.region.amazonaws.com" "svc-confluence-sit" "1.0.0"

REGISTRY=$1
PREFIX=$2
VERSION=$3

declare -a containers=("init-workflow")

for container in "${containers[@]}"; do
    echo $container
    deploy/deploy-ecr.sh $REGISTRY $PREFIX-$container

    container_underscore=${container//-/_}
    image_tag=$(echo $VERSION | cut -c1-5)

    docker pull ghcr.io/swot-confluence/${container_underscore}:latest

    docker tag ghcr.io/swot-confluence/${container_underscore}:latest $REGISTRY/$PREFIX-$container:$image_tag
    docker push $REGISTRY/$PREFIX-$container:$image_tag

    docker tag ghcr.io/swot-confluence/${container_underscore}:latest $REGISTRY/$PREFIX-$container:latest
    docker push $REGISTRY/$PREFIX-$container:latest
done

exit 0
