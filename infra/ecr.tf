resource "aws_ecr_repository" "backend" {
  name = "devops-backend"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "DevOps-Assignment"
  }
}

output "backend_repo_url" {
  value = aws_ecr_repository.backend.repository_url
}

resource "aws_ecr_repository" "frontend" {
  name = "devops-frontend"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "DevOps-Assignment"
  }
}

output "frontend_repo_url" {
  value = aws_ecr_repository.frontend.repository_url
}
