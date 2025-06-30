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

  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "docker_registry_image" "confluence" {
  for_each = local.images
  name = each.value.source_name
}

resource "terraform_data" "docker_ecr_login" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = "echo ${data.aws_ecr_authorization_token.default.authorization_token} | base64 --decode | cut -d ':' -f 2 | docker login -u AWS --password-stdin ${data.aws_ecr_authorization_token.default.proxy_endpoint}"
  }
}

resource "terraform_data" "docker_registry_image" {
  for_each = data.docker_registry_image.confluence
  depends_on = [
    terraform_data.docker_ecr_login,
    aws_ecr_repository.confluence
  ]
  triggers_replace = [ each.value.sha256_digest ]
  input = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.prefix}-${regex(".+\\/(.+)", each.value.name)[0]}"

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<EOF
      set -eo pipefail
      docker pull "${each.value.name}"
      docker tag "${each.value.name}" "${self.input}"
      docker push "${self.input}"
      docker rmi "${each.value.name}" "${self.input}"
    EOF
  }
}
