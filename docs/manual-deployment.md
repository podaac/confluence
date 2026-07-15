# Manual Deployment Guide

This document translates the automated `Deploy` GitHub Actions workflow
(`.github/workflows/deploy.yml`) into steps you can run by hand from a
local machine. It is useful when you need to deploy without pushing to
GitHub (e.g. testing a branch, debugging a failed deploy, or deploying
from a machine without CI access).

The workflow has two logical phases that this guide mirrors:

1. **Terraform deploy** — provisions/updates all AWS infrastructure.
2. **Docker image sync** — pulls the versioned component images from
   GHCR, scans them with Trivy, and pushes them to the account's ECR.

---

## 1. Prerequisites

### Tools

Install these on your local machine:

| Tool | Used for | Notes |
|---|---|---|
| [Terraform](https://developer.hashicorp.com/terraform/install) | Infra deploy | Match the version pinned by `hashicorp/setup-terraform` in CI if possible |
| [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) | AWS auth | Used to obtain credentials and to log in to ECR |
| [Docker](https://docs.docker.com/get-docker/) | Image sync | Needed to pull/tag/push component images |
| [Trivy](https://aquasecurity.github.io/trivy/latest/getting-started/installation/) | Image scan | `sync_docker_images.py` shells out to `trivy image ...` |
| Python 3.10+ | Image sync script | Only the standard library is used by `scripts/sync_docker_images.py`, no poetry install is required to run it |
| `envsubst` (part of `gettext`) | Terraform templating | `bin/config.sh` uses it to render `confluence.tf.tmpl` → `confluence.tf`. On macOS: `brew install gettext && brew link --force gettext` |
| `git` | Checkout | Clone with submodules if any are configured for the branch you're deploying |

### Access

- AWS credentials for the target account/venue (SIT, UAT, or OPS) with
  permission to manage the Batch/EFS/IAM/S3/Step Functions/ECR resources
  this stack creates.
- A GHCR (`ghcr.io`) login with read access to the `SWOT-Confluence`
  component images (a GitHub personal access token with `read:packages`
  works for `docker login ghcr.io`).
- Read access to the private Terraform module repos referenced from
  `terraform/main.tf` (see [Modules referenced](#3-modules-referenced),
  they're pulled directly from GitHub via `git::https://...`).

### Pre-existing AWS resources (this stack does not create these)

This repo's Terraform only *looks up* the following — it never creates
them — so they must already exist in the target AWS account before you
run `terraform init`/`apply`, or those steps will fail:

- **A VPC** tagged `Name = "Application VPC"` (see
  [§6, Adapting `network.tf`](#6-adapting-networktf-for-a-different-aws-account)
  if the target account tags/names things differently).
- **Subnets** inside that VPC tagged to match `network.tf`'s
  `tag:Name` filters (`"Private application*"`, and optionally
  `"Extension 1 - Private application*"`).
- **A `default` security group** in that VPC (every VPC has one
  automatically, so this is usually a non-issue).
- **An S3 bucket** for Terraform remote state, matching
  `BACKEND_BUCKET` in `env/<environment>.env` (e.g.
  `podaac-services-sit-terraform`). Terraform's S3 backend never
  creates this bucket for you — `terraform init` will fail without it.

If you're standing up a brand-new venue (e.g. the initial PO.DAAC →
JPL/SWOT handoff into a fresh AWS account), all four of these need to
be provisioned first — typically as part of that account's baseline
NGAP/account setup — before anything in this guide will work.

---

## 2. Set up your environment

```bash
git clone --recursive git@github.com:podaac/confluence.git
cd confluence/terraform
```

### 2.1 Authenticate to AWS

Export credentials for the venue you're deploying to (these correspond
to the `AWS_ACCESS_KEY_ID_SERVICES_<ENV>` / `AWS_SECRET_ACCESS_KEY_SERVICES_<ENV>`
GitHub secrets in CI):

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-west-2
```

(or use `aws sso login` / a named profile + `AWS_PROFILE`, whatever your
org uses — CI just uses static keys via `aws-actions/configure-aws-credentials`).

### 2.2 Log in to the container registries

```bash
# GHCR (source of the component images)
echo "$GHCR_TOKEN" | docker login ghcr.io -u <your-github-username> --password-stdin

# ECR (destination — uses your already-exported AWS credentials)
aws ecr get-login-password --region us-west-2 \
  | docker login --username AWS --password-stdin "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-west-2.amazonaws.com"
```

`sync_docker_images.py` (step 4 below) reads credentials for both
registries out of `~/.docker/config.json`, so both logins above need to
have happened first.

### 2.3 Set the required Terraform variables

`terraform/bin/config.sh` sources `terraform/env/<environment>.env` for
non-secret, per-venue settings (backend bucket, component image
versions, deployment prefix — see `terraform/env/sit.env` for the SIT
example). Only `sit.env` exists in the repo today; add `uat.env` /
`ops.env` following the same pattern if you're deploying to those
venues for the first time.

Secrets are **not** stored in the repo — in CI they come from GitHub
Actions secrets and are exported as `TF_VAR_*` right before `deploy.sh`
runs (see `deploy.yml` step "Define TF_VAR values"). Do the same
locally, e.g.:

```bash
export TF_VAR_hydrocron_api_key="<hydrocron api key - get from PO.DAAC>"
export TF_VAR_ec2_key_pair="<ec2 key pair name for this venue>"
export TF_VAR_sns_email_reports="<sns reports topic email>"
export TF_VAR_sns_email_alarms="<sns alarms topic email>"
export TF_VAR_lpdaac_username="<edl username>"
export TF_VAR_lpdaac_password="<edl password>"
export TF_VAR_app_version="<version to tag resources with, e.g. output of 'poetry version -s'>"
```

> A `terraform/terraform.tfvars` or `terraform/env/<env>.tfvars` file is
> **not** used by `bin/deploy.sh` — everything is driven by `TF_VAR_*`
> environment variables plus `env/<environment>.env`. If you keep a
> local `.tfvars` scratch file for convenience, make sure it's never
> committed (it will contain plaintext secrets) — both
> `terraform/terraform.tfvars` and `terraform/env/sit.tfvars` are
> currently untracked in this checkout; double check they're covered by
> `.gitignore` before running `git add`.

---

## 3. Modules referenced

`terraform/main.tf` composes the stack from two categories of remote
modules, all pulled straight from GitHub via `git::https://...?ref=<version>`
(the `$FOO_VERSION` placeholders are substituted from `env/<env>.env` by
`envsubst` when `confluence.tf.tmpl` is rendered into `confluence.tf`):

- **Shared infrastructure** (from `SWOT-Confluence/confluence-terraform`):
  - `workflow-infrastructure/modules/infra` (VPC/EFS/IAM/Batch/S3/etc.) — `INFRA_VERSION`
  - `workflow-step-function/modules/sfn` (Step Function/EventBridge) — `SFN_VERSION`
- **Per-component workflow modules**, one per SWOT-Confluence pipeline
  step, each wired to the shared infra's EFS file systems and IAM roles
  (clean_up, combine_data, init_workflow, input, lakeflow, metroman,
  metroman_consolidation, moi, momma, busboi, coastalQ, offline, output,
  postdiagnostics, prediagnostics, priors, report, setfinder, sic4dvar,
  ssc_input, ssc_model_deployment, validation, hivdi, consensus — see
  `terraform/main.tf` for the exact source repo + path per module, and
  `terraform/env/sit.env` for their pinned versions). A couple
  (`neobam`, `sad`) are currently commented out in `main.tf`.

`terraform/ecr.tf` additionally creates one ECR repository per entry in
`var.docker_images` (`terraform/variables.tf`) and exposes the
`docker_images` / `source_docker_registry` / `destination_docker_registry`
outputs that the sync step (below) reads.

You don't need to clone these module repos yourself — Terraform fetches
them during `terraform init`, as long as your git credentials can reach
them.

---

## 4. Run the Terraform deploy

From `terraform/`:

```bash
./bin/deploy.sh <environment> -auto-approve
```

where `<environment>` is the lowercase venue name (`sit`, `uat`, `ops`)
matching an `env/<environment>.env` file. This is the same command CI
runs (`./bin/deploy.sh ${TARGET_ENV_LOWERCASE} -auto-approve`).

Under the hood, `deploy.sh` sources `bin/config.sh`, which:

1. `cd`s into `terraform/`.
2. Sources `env/<environment>.env` (backend bucket, prefix, module versions).
3. Sets `TF_IN_AUTOMATION=true`, `TF_INPUT=false`.
4. Sets `TF_VAR_app_version`, `TF_VAR_region`, `TF_VAR_environment`.
5. Renders `confluence.tf.tmpl` → `confluence.tf` via `envsubst` (this
   is what fills in each module's `?ref=$FOO_VERSION`).
6. Runs `terraform init -backend-config="bucket=$BACKEND_BUCKET" -reconfigure`.

...then `deploy.sh` runs `terraform apply $@` (the `-auto-approve` you
passed gets forwarded here). Drop `-auto-approve` if you want to review
the plan interactively first, or use `./bin/plan.sh <environment>` to
only run `terraform plan`.

To tear the stack down later: `./bin/destroy.sh <environment>`.

---

## 5. What the Terraform apply creates

Everything below is a `resource` (not a `data` lookup), so it's newly
created (or updated) in the target AWS account by the `apply` in step
4 — as opposed to the pre-existing VPC/subnets/state bucket from §1,
which are only ever read.

### Top level (`terraform/*.tf`)

- **ECR repositories** (`ecr.tf`) — one per entry in `var.docker_images`
  (`terraform/variables.tf`), named `${prefix}-<image-name>`. These are
  the push targets for the [Docker image sync step](#7-sync-docker-images).
- **CloudWatch alarm + SNS topic** (`confluence-alarm.tf`) — a Fargate
  vCPU-usage alarm (`${prefix}-fargate-vcpu-alarm`) that emails
  `TF_VAR_sns_email_alarms` via a dedicated
  `${prefix}-cloudwatch-alarms` SNS topic.

### `module "infrastructure"` (shared infra, one per venue)

- **S3 buckets** — `${prefix}-sos`, `${prefix}-json`, `${prefix}-config`
  (see previous answer above for details: encrypted, private, bucket-owner-enforced).
- **Batch compute environments** (4) — data, diagnostics, flpe, and
  discharge-metrics.
- **Batch job queues** (24) — one per pipeline stage (combine_data,
  setfinder, flpe, input, moi, offline, output, postdiagnostics ×2,
  prediagnostics, prior, validation, consensus, init_workflow, report,
  clean_up, ssc_input, ssc_model_deploy, lakeflow_input, lakeflow_deploy, ...).
- **EFS file systems + mount targets** (8) — logs, val, off, out, diag,
  moi, in, flpe — plus a dedicated EFS security group.
- **EC2 launch template + IAM role/instance profile** for EFS-backed
  compute instances.
- **IAM roles** — Batch service role, ECS task execution role, and the
  Batch job role (with attached S3, Step-Function, SSM, and SNS
  policies) that every component module's jobs run as.
- **SNS topic** (+ policy + subscription) for Confluence report emails
  (`TF_VAR_sns_email_reports`).
- **SSM parameters** — `lpdaac_user` / `lpdaac_password` (stored so
  Batch jobs can read LPDAAC credentials at runtime).

### `module "step_function"`

- **Step Function state machine** (`confluence_state_machine`) that
  orchestrates the whole pipeline, its own **IAM role** (cloudwatch,
  x-ray, eventbridge, batch, s3, and states policies), and a
  **CloudWatch log group** for its execution history.

### Every per-component module (clean_up, combine_data, init_workflow, input, lakeflow, metroman, metroman_consolidation, moi, momma, busboi, coastalQ, offline, output, postdiagnostics, prediagnostics, priors, report, setfinder, sic4dvar, ssc_input, ssc_model_deployment, validation, hivdi, consensus)

Each follows the same pattern (e.g. `clean_up`'s
`confluence-clean-up.tf`):

- One **AWS Batch job definition**, referencing the ECR image/tag for
  that component and the shared exec/job IAM roles + EFS mounts from
  `module.infrastructure`.
- One **CloudWatch log group** for that job's container logs.

None of the per-component modules provision their own S3 buckets, IAM
roles, or networking — they all plug into the shared resources created
by `module.infrastructure` above.

---

## 6. Adapting `network.tf` for a different AWS account

`terraform/network.tf` doesn't create any networking — it looks up
network resources that must **already exist** in the target AWS
account, by tag:

```hcl
data "aws_vpc" "application_vpc" {
  tags = { "Name" : "Application VPC" }
}

data "aws_subnets" "extended_private_app" {
  filter { name = "vpc-id"     values = [data.aws_vpc.application_vpc.id] }
  filter { name = "tag:Name"   values = ["Extension 1 - Private application*"] }
}

data "aws_subnets" "private_app" {
  filter { name = "vpc-id"     values = [data.aws_vpc.application_vpc.id] }
  filter { name = "tag:Name"   values = ["Private application*"] }
}

data "aws_security_group" "vpc_default_sg" {
  filter { name = "group-name" values = ["default"] }
  filter { name = "vpc-id"     values = [data.aws_vpc.application_vpc.id] }
}
```

Those four lookups feed `module "infrastructure"` in `main.tf`
(`vpc_id`, `vpc_subnets` via `local.subnet_ids`, `vpc_sg_id`). The
string values (`"Application VPC"`, `"Extension 1 - Private
application*"`, `"Private application*"`, `"default"`) match PO.DAAC's
NGAP tagging convention. When handing this off to an account with
different naming — e.g. moving a venue from PO.DAAC AWS to JPL/SWOT
AWS — these lookups will fail (0 or wrong matches) unless updated.

### Steps

1. **Find the real tag values in the target account.** Ask the account
   owner, or query directly with credentials for that account:

   ```bash
   # VPC name tags
   aws ec2 describe-vpcs \
     --query 'Vpcs[].Tags[?Key==`Name`].Value' --output text

   # Subnet name tags within that VPC
   aws ec2 describe-subnets \
     --filters "Name=vpc-id,Values=<vpc-id>" \
     --query 'Subnets[].Tags[?Key==`Name`].Value' --output text

   # Security groups in that VPC
   aws ec2 describe-security-groups \
     --filters "Name=vpc-id,Values=<vpc-id>" \
     --query 'SecurityGroups[].GroupName' --output text
   ```

2. **Edit `terraform/network.tf`** on the branch/checkout you're
   deploying from that venue, replacing the `tags`/`filter` values
   above with whatever the target account actually uses. The
   `extended_private_app` lookup is optional (`network.tf`'s
   `local.subnet_ids` falls back to `private_app` if it returns zero
   results) — if the target account has no "extension" subnets, it's
   fine to leave that block as-is; it'll just come back empty and be
   skipped automatically.

3. **Re-run `terraform plan`** (`./bin/plan.sh <environment>`) before
   applying, and confirm the plan only shows the expected
   infrastructure changes — not a wholesale VPC swap you didn't intend
   (a typo'd tag filter can silently match the wrong VPC/subnets rather
   than erroring).

> `network.tf` is a shared, tracked file — it isn't parameterized
> per-environment the way `env/<environment>.env` is. If this
> PO.DAAC → JPL handoff happens more than once, it's worth promoting
> these four strings to variables (with the current PO.DAAC values as
> defaults) so each venue can override them via `env/<environment>.env`
> / `TF_VAR_*` instead of hand-editing `network.tf` every time. Until
> then, keep a note of each venue's actual tag values somewhere durable
> (e.g. this doc, or the venue's `env/*.env` file as a comment) so the
> edit doesn't have to be rediscovered on the next handoff.

---

## 7. Sync Docker images

After the Terraform apply succeeds (the sync script reads Terraform
outputs, so it must run after `apply`, not before):

```bash
# from the repo root
python3 ./scripts/sync_docker_images.py
```

This script:

1. Runs `terraform output --json` (from `../terraform` relative to the
   script) to get the `docker_images`, `source_docker_registry`
   (`ghcr.io`), and `destination_docker_registry` (this account's ECR)
   outputs produced by `terraform/ecr.tf`.
2. For each image in `var.docker_images`, compares the GHCR source
   manifest digest against the ECR destination manifest digest (using
   the docker credentials you set up in step 2.2, read from
   `~/.docker/config.json`).
3. For any image that's missing or out of date in ECR:
   - `docker pull` the source image from GHCR.
   - `trivy image --severity HIGH,CRITICAL --format sarif` scan it,
     writing results to `../scans/<repo>.sarif`.
   - `docker tag` + `docker push` it to ECR.
   - `docker rmi` both local tags to free disk space.
4. Writes `synced_images=true|false` to `$GITHUB_OUTPUT` — since that
   env var won't be set locally, either export a dummy writable file
   path (`export GITHUB_OUTPUT=/tmp/gh_output`) before running the
   script, or expect it to fail on that last line and ignore it (the
   sync/scan/push work is already done by that point).

The `../scans/*.sarif` files are only uploaded to GitHub's Security tab
in CI (`github/codeql-action/upload-sarif`) — locally you can inspect
them directly with any SARIF viewer if you want to review the Trivy
findings.

---

## 8. Quick reference: end-to-end

```bash
cd confluence/terraform

# AWS + registry auth
export AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... AWS_DEFAULT_REGION=us-west-2
echo "$GHCR_TOKEN" | docker login ghcr.io -u <user> --password-stdin
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin "$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-west-2.amazonaws.com"

# Secrets terraform needs
export TF_VAR_hydrocron_api_key=... TF_VAR_ec2_key_pair=... \
       TF_VAR_sns_email_reports=... TF_VAR_sns_email_alarms=... \
       TF_VAR_lpdaac_username=... TF_VAR_lpdaac_password=... \
       TF_VAR_app_version=$(grep -m1 version ../pyproject.toml | awk -F' = ' '{print $2}' | tr -d '"')

# Deploy infra
./bin/deploy.sh sit -auto-approve

# Sync component images into ECR
cd ..
export GITHUB_OUTPUT=/tmp/gh_output
python3 ./scripts/sync_docker_images.py
```

## 9. Initial Setup

Before you can run the workflow, a set of files needs to be 
uncompressed and written to the `${prefix}-config` created in step 5. 
if you're not sure what your prefix is, login to AWS and view the buckets.

**Obtain the config file from PO.DAAC and deploy to your bucket** 
The files are available from PO.DAAC, request access to get a downloadable version of this either through LFT or from a PO.DAAC bucket. Note, the configuration tarball is 5GB *compressed*. This file is named `confluence-config-4.0.0.tar.gz`.

Once you have the file, you'll want to uncompress it and sync the new files to the `${prefix}-config` bucket with a command like the following:

```
mkdir -p /path/to/new_directory
tar -zxvf confluence-config-4.0.0.tar.gz -C /path/to/new_directory
aws s3 sync /path/to/new_directory/ s3://${prefix}-config/

```

This will extract and send the files to your configuration directory. It is recommended you do this step from a machine in AWS to expedite the transfers.

## 10. Execution of main workflow

Once you have completed the above steps, you can go ahead and execute the confluence step function with the default parameters.

In the AWS Console,

1. NAvigate to the "Step Function" page in AWS console. you should see a listing of "state machines". Select the one that is titled `${prefix}-workflow` (for example, svc-confluence-sit-workflow).
2. Click "New Execution" and a window will pop up.
3. Enter the following json for a sample execution:

```
{
  "version": "0004",
  "run_type": "unconstrained",
  "reach_subset_file": "reaches_of_interest.json",
  "temporal_range": "&start_time=2020-09-01T00:00:00Z&end_time=2026-11-10T16:20:46Z&",
  "tolerated_failure_percentage": "50",
  "run_gbpriors": "true",
  "run_postdiagnostics": "false",
  "run_ssc": "false",
  "skip_priors": "true",
  "run_lakeflow": "false",
  "counter": "run-0001",
  "recover": "false",
  "offline": "true"
}
```
Some of these will never change, the oens that will change will be "run_ssc" and "run_lakeflow" when doing larger runs, and "recover" when resuming a previously failed run.

4. Select "Start execution" to begin the run. You will be able to monitor the run through the statemachine UI.

## 11. Execution of SSC workflow

Once complete, you should have several files in the `${prefix}-sos` bucket under the prefix `unconstrained/0002/`. You'll see files like:

`na_sword_v17_SOS_results_20230329T085248_20260709T172420_20260713T165025.nc` which is coded as <continent>_sword_v17_SOS_results_<coverage_start_time>_<coverage_endtime>_<output_production_time>.

For the short run we've just done, only the "na" continent should exist. 

We need to create a _map_ file for the SSC (suspended sediment concentration), with the following format:

```
[
  {"continent":"$CONTINENT","results":"/mnt/output/sos/$CONTINENT_sword_v17_SOS_results_<coverage_start_time>_<coverage_end_time>_<output_production_time>.nc"}
]
```

For example:

```
[
  {"continent":"na","results":"/mnt/output/sos/na_sword_v17_SOS_results_20230329T085248_20260624T152656_20260701T053011.nc"}
]
```

These files exist on the /mnt/output/sos of batch jobs that will soon run, we are simply mapping to them as the names change every time we run the main workflow (due to the output production time)

Once we have this, we can execute the SSC workflow.

1. NAvigate to the "Step Function" page in AWS console. you should see a listing of "state machines". Select the one that is titled `${prefix}-workflow-ssc` (for example, svc-confluence-sit-workflow-ssc).
2. Click "New Execution" and a window will pop up.
3. Enter the following json for a sample execution:

```
{
  "version": "0004",
  "run_type": "unconstrained",
  "reach_subset_file": "reaches_of_interest.json",
  "temporal_range": "&start_time=2020-09-01T00:00:00Z&end_time=2026-11-10T16:20:46Z&",
  "tolerated_failure_percentage": "50",
  "include_lakeflow": "false",
  "counter": "test-run-0008",
  "recover": "false"
}
```

Again, most of these will not change. include_lakeflow will be true on the main run, and recover will be true if we resume from a failed run. 

4. Select "Start execution" to begin the run. You will be able to monitor the run through the statemachine UI.

