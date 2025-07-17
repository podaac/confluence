#!/usr/bin/env bash
set -eo pipefail

if [ $# -eq 0 ]
then
    echo "$(caller | cut -d' ' -f2) environment"
    exit 1
fi

cd "$(dirname $BASH_SOURCE)/../"

export ENVIRONMENT=$1
shift

source env/$ENVIRONMENT.env

export TF_IN_AUTOMATION="true"  # https://www.terraform.io/cli/config/environment-variables#tf_in_automation
export TF_INPUT="false"  # https://www.terraform.io/cli/config/environment-variables#tf_input

export TF_VAR_region="$AWS_REGION"
export TF_VAR_environment="$ENVIRONMENT"

# Generate confluence.tf from template
envsubst < confluence.tf.tmpl > confluence.tf

terraform init -backend-config="bucket=$BACKEND_BUCKET" -reconfigure
