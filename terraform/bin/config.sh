#!/usr/bin/env bash
set -eo pipefail

if [ ! $# -eq 1 ]
then
    echo "$(caller | cut -d' ' -f2) environment"
    exit 1
fi

export APP_VERSION="${APP_VERSION:=$(grep -m 1 version pyproject.toml | awk -F ' = ' '{print $2}' | sed 's/"//g')}"
export ENVIRONMENT=$1
shift

cd "$(dirname $BASH_SOURCE)/../"
source env/$ENVIRONMENT.env

export TF_IN_AUTOMATION="true"  # https://www.terraform.io/cli/config/environment-variables#tf_in_automation
export TF_INPUT="false"  # https://www.terraform.io/cli/config/environment-variables#tf_input

export TF_VAR_app_version="$APP_VERSION"
export TF_VAR_region="$AWS_REGION"
export TF_VAR_environment="$ENVIRONMENT"

# Generate confluence.tf from template
envsubst < confluence.tf.tmpl > confluence.tf

terraform init -backend-config="bucket=$BACKEND_BUCKET" -reconfigure
