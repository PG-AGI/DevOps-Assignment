# terraform/aws/ecr.tf

resource "aws_ecr_repository" "backend" {
  name                 = "devops-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_repository" "frontend" {
  name                 = "devops-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

