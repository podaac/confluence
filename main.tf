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
  region  = var.aws_region
}

# Data
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

data "aws_security_groups" "vpc_default_sg" {
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
  source            = "./confluence-terraform/workflow-infrastructure"
  app_name          = var.app_name
  app_version       = var.app_version
  aws_region        = var.aws_region
  ec2_key_pair      = var.ec2_key_pair
  sns_email_reports = var.sns_email_reports
  environment       = var.environment
  prefix            = var.prefix
  vpc_id            = data.aws_vpc.application_vpc.id
  vpc_sg_id         = data.aws_security_groups.vpc_default_sg.id
  vpc_subnets       = values(data.aws_subnet.private_application_subnet_list).*.id
}
