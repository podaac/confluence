resource "aws_ecr_repository" "confluence" {
  for_each = toset(var.docker_images)
  name = each.value

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_authorization_token" "default" {}

data "docker_registry_image" "confluence" {
  for_each = aws_ecr_repository.confluence
  name = "${var.docker_registry}/${each.value.name}:${var.app_version}"
}

resource "docker_image" "confluence" {
  for_each = data.docker_registry_image.confluence
  name = each.value.name
  pull_triggers = [each.value.sha256_digest]
}

resource "docker_tag" "confluence" {
  for_each = docker_image.confluence
  source_image = each.value.name
  target_image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${regex(".+\\/(.+\\/.+)", each.value.name)[0]}"
}

resource "docker_registry_image" "confluence" {
  for_each = docker_tag.confluence
  lifecycle {
    ignore_changes = [auth_config]
  }
  name = each.value.target_image
  keep_remotely = true

  auth_config {
    address = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    username = data.aws_ecr_authorization_token.default.user_name
    password = data.aws_ecr_authorization_token.default.password
  }
}
