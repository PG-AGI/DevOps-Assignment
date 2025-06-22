output "ecr_urls" {
  value = {
    for repo in aws_ecr_repository.app_repos :
    repo.name => repo.repository_url
  }
}

