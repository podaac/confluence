variable "app_name" {
  type        = string
  description = "Application name"
  default     = "confluence"
}

variable "app_version" {
  type        = number
  description = "The application version number"
  default     = 0.1
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

variable "ssh_subnet" {
  type        = string
  description = "CIDR range to allow SSH from to EC2 EFS"
  sensitive = true
}

variable "subnet_a_public_cidr" {
  type        = string
  description = "CIDR range for public subnet in us-west-2a"
  sensitive = true
}

variable "subnet_a_private_cidr" {
  type        = string
  description = "CIDR range for private subnet in us-west-2a"
  sensitive = true
}

variable "subnet_b_cidr" {
  type        = string
  description = "CIDR range for private subnet in us-west-2a"
  sensitive = true
}

variable "subnet_c_cidr" {
  type        = string
  description = "CIDR range for private subnet in us-west-2a"
  sensitive = true
}

variable "subnet_d_cidr" {
  type        = string
  description = "CIDR range for private subnet in us-west-2a"
  sensitive = true
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR range for VPC"
  sensitive = true
}