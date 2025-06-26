data "aws_ecr_authorization_token" "default" {}

locals {
  images = {
    for image in var.docker_images : image => {
      source_name = "${var.docker_registry}/${image}:${var.app_version}"
      destination_repository = "${var.prefix}-${regex(".+\\/(.+)",image)[0]}"
      destination_name = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.prefix}-${regex(".+\\/(.+)",image)[0]}:${var.app_version}"
    }
  }
}

data "docker_registry_image" "confluence" {
  for_each = local.images
  name = each.value.source_name
}

resource "docker_image" "confluence" {
  for_each = data.docker_registry_image.confluence
  name = each.value.name
  pull_triggers = [each.value.sha256_digest]
}

resource "aws_ecr_repository" "confluence" {
  for_each = local.images
  name = each.value.destination_repository

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "docker_tag" "confluence" {
  depends_on = [ docker_image.confluence ]

  for_each = local.images
  source_image = "${each.value.source_name}"
  target_image = "${each.value.destination_name}"
}

resource "docker_registry_image" "confluence" {
  depends_on = [ aws_ecr_repository.confluence ]
  for_each = docker_tag.confluence

  name = each.value.target_image
  keep_remotely = true

  lifecycle {
    ignore_changes = [auth_config]
  }

  auth_config {
    address = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    username = data.aws_ecr_authorization_token.default.user_name
    password = data.aws_ecr_authorization_token.default.password
  }
}
