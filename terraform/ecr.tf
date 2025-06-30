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

resource "aws_ecr_repository" "confluence" {
  for_each = local.images
  name = each.value.destination_repository

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "docker_registry_image" "confluence" {
  for_each = local.images
  name = each.value.source_name
}

resource "terraform_data" "docker_registry_image" {
  for_each = data.docker_registry_image.confluence

  lifecycle {
    replace_triggered_by = [ each.value.sha256_digest ]
  }

  provisioner "local-exec" {
    command = (
      "docker pull ${each.value.name} && " +
      "docker tag ${each.value.name} ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.prefix}-${regex(".+\\/(.+)",image)[0]}:${var.app_version} && " +
      "docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.prefix}-${regex(".+\\/(.+)",image)[0]}:${var.app_version} && " +
      "docker rmi ${each.value.name} ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.prefix}-${regex(".+\\/(.+)",image)[0]}:${var.app_version}"
    )
}
