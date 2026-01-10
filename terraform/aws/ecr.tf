# -----------------------
# ECR Repository for Backend
# -----------------------
resource "aws_ecr_repository" "backend_repo" {
  name                 = "devops-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "devops-backend-repo"
  }
}

