variable "api_key" {
  type        = string
  description = "API key to query Hydrocron"
}

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
}

variable "lpdaac_user" {
  type        = string
  description = "Username to retrieve LPDAAC data"
}

variable "lpdaac_password" {
  type        = string
  description = "Password to retrieve LPDAAC data"
}

variable "sns_email_reports" {
  type        = string
  description = "Email address to SNS topic reports to"
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
  type = list(string)
  description = "List of Docker container images to push to ECR"
  default = [
    "swot-confluence/clean_up"
  ]
}

variable "docker_registry" {
  type = string
  description = "Docker container registry to pull images from"
  default = "ghcr.io"
}
