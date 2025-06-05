resource "aws_ecr_repository" "confluence" {
  name = var.prefix

  image_scanning_configuration {
    scan_on_push = true
  }
}



data aws_ecr_authorization_token "default" {}
