data "aws_ecr_authorization_token" "default" {}

locals {
  source_docker_registry      = var.docker_registry
  destination_docker_registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"

  images = {
    for image in var.docker_images : image => {
      source_name            = "${var.docker_registry}/${image}:${var.confluence_app_version}"
      destination_repository = "${var.prefix}-${regex(".+\\/(.+)", image)[0]}"
      destination_name       = "${local.destination_docker_registry}/${var.prefix}-${regex(".+\\/(.+)", image)[0]}:${var.confluence_app_version}"
    }
  }
}

resource "aws_ecr_repository" "confluence" {
  for_each = local.images
  name     = each.value.destination_repository

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "docker_images" {
  value = local.images
}

output "source_docker_registry" {
  value = local.source_docker_registry
}

output "destination_docker_registry" {
  value = local.destination_docker_registry
}
