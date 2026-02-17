terraform {
  required_version = ">= 1.0"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

resource "aws_ecr_repository" "strapi" {
  name                 = "strapi"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }

  lifecycle {
    create_before_destroy = true
  }
}
