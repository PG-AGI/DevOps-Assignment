resource "aws_ecr_repository" "app_repos" {
  for_each = toset(var.ecr_repos)

  name = each.key

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project = "DevOpsAssignment"
    Environment = "Dev"
  }
}

