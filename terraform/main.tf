terraform {
  backend "s3" {
    encrypt = true
    key = "services/confluence/terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "3.3.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = local.default_tags
  }
  ignore_tags {
    key_prefixes = ["gsfc-ngap"]
  }
  region  = var.aws_region
}

provider "docker" {}

# Data
data "aws_caller_identity" "current" {}

data "local_file" "pyproject_toml" {
  filename = "${path.module}/../pyproject.toml"
}

# Locals
locals {
  account_id = data.aws_caller_identity.current.account_id
  app_version = var.app_version != null ? var.app_version : (
    regex("version = \"([0-9]+\\.[0-9]+\\.[0-9]+)\"", data.local_file.pyproject_toml.content)[0]
  )
  default_tags = length(var.default_tags) == 0 ? {
    application : var.app_name,
    environment : lower(var.environment),
    version : local.app_version
  } : var.default_tags
}
