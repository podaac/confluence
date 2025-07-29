variable "app_name" {
  type        = string
  description = "Application name"
  default     = "confluence"
}

variable "app_version" {
  type        = string
  description = "The application version number"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy to"
  default     = "us-west-2"
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "ec2_key_pair" {
  type        = string
  description = "Key pair used to access EFS EC2 instances"
  sensitive   = true
}

variable "hydrocron_api_key" {
  type        = string
  description = "API key to query Hydrocron"
  sensitive   = true
}

variable "lpdaac_username" {
  type        = string
  description = "Username to retrieve LPDAAC data"
  sensitive   = true
}

variable "lpdaac_password" {
  type        = string
  description = "Password to retrieve LPDAAC data"
  sensitive   = true
}

variable "sns_email_reports" {
  type        = string
  description = "Email address to SNS topic reports to"
  sensitive   = true
}

variable "sns_email_alarms" {
  type        = string
  description = "Email address to Cloud Metric Alarm notifications to"
}

variable "environment" {
  type        = string
  description = "The environment in which to deploy to"
}

variable "prefix" {
  type        = string
  description = "Prefix to add to all AWS resources as a unique identifier"
}

variable "docker_images" {
  type        = list(string)
  description = "List of Docker container images to push to ECR"
  default = [
    "swot-confluence/clean_up",
    "swot-confluence/combine_data",
    "swot-confluence/init_workflow",
    "swot-confluence/input",
    "swot-confluence/lakeflow_deploy",
    "swot-confluence/lakeflow_input",
    "swot-confluence/metroman",
    "swot-confluence/metroman_consolidation",
    "swot-confluence/moi",
    "swot-confluence/momma",
    "swot-confluence/neobam",
    "swot-confluence/offline-discharge-data-product-creation",
    "swot-confluence/output",
    "swot-confluence/postdiagnostics_moi",
    "swot-confluence/postdiagnostics_flpe",
    "swot-confluence/prediagnostics",
    "swot-confluence/priors",
    "swot-confluence/report",
    "swot-confluence/sad",
    "swot-confluence/setfinder",
    "swot-confluence/sic4dvar",
    "swot-confluence/ssc_input",
    "swot-confluence/ssc_model_deployment",
    "swot-confluence/validation"
  ]
}

variable "docker_registry" {
  type        = string
  description = "Docker container registry to pull images from"
  default     = "ghcr.io"
}

variable "confluence_app_version" {
  type        = string
  description = "Workflow application version defined by the SWOT Confluence team"
}
