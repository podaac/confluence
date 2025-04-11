terraform {
  backend "s3" {
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = local.default_tags
  }
  region  = var.aws_region
}

# Locals
locals {
  account_id = data.aws_caller_identity.current.account_id
  default_tags = length(var.default_tags) == 0 ? {
    application : var.app_name,
    environment : lower(var.environment),
    version : var.app_version
  } : var.default_tags
}

# Data
data "aws_caller_identity" "current" {}

data "aws_vpc" "application_vpc" {
  tags = {
    "Name" : "Application VPC"
  }
}

data "aws_subnets" "private_application_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.application_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["Private application*"]
  }
}

data "aws_subnet" "private_application_subnet_list" {
  for_each = toset(data.aws_subnets.private_application_subnets.ids)
  id       = each.value
}

data "aws_security_group" "vpc_default_sg" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.application_vpc.id]
  }
}

# Infrastructure
module "confluence-terraform" {
  source            = "git::https://github.com/SWOT-Confluence/confluence-terraform//workflow-infrastructure/modules/infra?ref=1.0.0"
  app_name          = var.app_name
  app_version       = var.app_version
  aws_region        = var.aws_region
  ec2_key_pair      = var.ec2_key_pair
  sns_email_reports = var.sns_email_reports
  environment       = var.environment
  prefix            = var.prefix
  vpc_id            = data.aws_vpc.application_vpc.id
  vpc_sg_id         = data.aws_security_group.vpc_default_sg.id
  vpc_subnets       = values(data.aws_subnet.private_application_subnet_list).*.id
}

# Init Workflow
module "init-workflow" {
  source            = "git::https://github.com/SWOT-Confluence/init_workflow//terraform/modules/init?ref=1.0.0"
  app_name          = var.app_name
  app_version       = var.app_version
  aws_region        = var.aws_region
  environment       = var.environment
  prefix            = var.prefix
}