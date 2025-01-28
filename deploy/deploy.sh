#!/bin/bash
#
# Script to deploy Terraform AWS infrastructure
#
# REQUIRES:
#   AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
#   Terraform (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
#
# Command line arguments:
# [1] s3_state_bucket: Name of the S3 bucket to store Terraform state in (no need for s3:// prefix)
# [2] terraform_state_key: Name of Terraform state key (e.g. confluence.tfstate or confluence-sfn.tfstate)
# [3] terraform_directory: Which directory to deploy (e.g. workflow-infrastructure)
# 
# Example usage: ./deploy.sh "s3-state-bucket-name" "terraform-state-key" "terraform-directory"

S3_STATE=$1
TF_STATE_KEY=$2
TF_DIR=$3

cwd=$PWD
cd $TF_DIR
terraform init -reconfigure -backend-config="bucket=$S3_STATE" -backend-config="key=$TF_STATE_KEY" -backend-config="region=us-west-2"
terraform apply -auto-approve
cd $cwd
