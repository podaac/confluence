# confluence

## components

![Confluence Component Data Flow Diagram](diagrams/confluence-data-flow.png)

Confluence repositories:

- Clean Up: https://github.com/podaac/confluence_clean_up
- Combine Data:https://github.com/podaac/confluence_combine_data
- Init Workflow: https://github.com/podaac/confluence_init_workflow
- Input: https://github.com/podaac/confluence_input
- MetroMan: https://github.com/podaac/confluence_metroman
- MetroMan Consolidation: https://github.com/podaac/confluence_metroman_consolidation
- MOI: https://github.com/podaac/confluence_moi
- MOMMA: https://github.com/podaac/confluence_momma
- neoBAM: https://github.com/podaac/confluence_neobam
- Offline: https://github.com/podaac/confluence_offline
- Output: https://github.com/podaac/confluence_output
- Postdiagnostics: https://github.com/podaac/confluence_postdiagnostics
- Prediagnostics: https://github.com/podaac/confluence_prediagnostics
- Priors: https://github.com/podaac/confluence_priors
- Report: https://github.com/podaac/confluence_report
- SAD: https://github.com/podaac/confluence_sad
- Setfinder: https://github.com/podaac/confluence_setfinder
- SoS Read: https://github.com/podaac/confluence_sos_read
- Validation: https://github.com/podaac/confluence_validation

## aws infrastructure

### workflow-infrastructure

The Confluence workflow includes the following AWS service in the `workflow-infrastructure` directory

- AWS Batch compute environment, job queue definitions.
- AWS CloudWatch Logs.
- AWS EFS.
- AWS IAM Roles & Policies.
- AWS S3 SoS Bucket.
- AWS Security Groups and VPC definition.
- AWS System Manager Parameter Store and Key Management Service.

### stepfunction-infrastructure

The Confluence workflow includes the following AWS service in the `stepfunction-infrastructure` directory

- AWS EventBridge rule.
- AWS Step Function state machine.
- AWS IAM Roles & Policies.

## terraform

Deploys AWS infrastructure and stores state in an S3 backend. This top-level terraform repo contains AWS infrastructure that applies to all components. Each component may have additional terraform files for deploying AWS resources, see each components `README.md` for details.

To deploy:

1. Edit `conf.tfvars` for environment to deploy to.
2. Initialize terraform: `terraform init -reconfigure -backend-config="bucket=confluence-<env>-tf-state" -backend-config="key=confluence.tfstate" -backend-config="region=us-west-2" -backend-config="profile=<named_profile>"`
3. Plan terraform modifications: `terraform plan -var-file="conf.tfvars" -out="tfplan"`
4. Apply terraform modifications: `terraform apply tfplan`

`<env>` can be `dev1`, `dev2`, `dev3` or `ops`

`<named_profile>` is the name of the profile used to authenticate to AWS

### deployment script

Script to deploy Terraform AWS infrastructure

REQUIRES:
  
- AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Terraform (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

Command line arguments:

[1] s3_state_bucket: Name of the S3 bucket to store Terraform state in (no need for s3:// prefix)

[2] profile: Name of profile used to authenticate AWS CLI commands

Example usage: `./deploy.sh "s3-state-bucket-name" "confluence-named-profile"`
