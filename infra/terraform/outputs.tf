# Terraform Outputs

# AWS Outputs
output "aws_backend_url" {
  description = "URL of the AWS backend load balancer"
  value       = var.deploy_to_aws ? module.aws_infrastructure[0].backend_url : null
}

output "aws_frontend_url" {
  description = "URL of the AWS frontend load balancer"
  value       = var.deploy_to_aws ? module.aws_infrastructure[0].frontend_url : null
}

output "aws_ecr_backend_repository_url" {
  description = "AWS ECR repository URL for backend"
  value       = var.deploy_to_aws ? module.aws_infrastructure[0].ecr_backend_repository_url : null
}

output "aws_ecr_frontend_repository_url" {
  description = "AWS ECR repository URL for frontend"
  value       = var.deploy_to_aws ? module.aws_infrastructure[0].ecr_frontend_repository_url : null
}

output "aws_ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = var.deploy_to_aws ? module.aws_infrastructure[0].ecs_cluster_name : null
}

output "aws_vpc_id" {
  description = "ID of the AWS VPC"
  value       = var.deploy_to_aws ? module.aws_infrastructure[0].vpc_id : null
}

# GCP Outputs
output "gcp_backend_url" {
  description = "URL of the GCP Cloud Run backend service"
  value       = var.deploy_to_gcp ? module.gcp_infrastructure[0].backend_url : null
}

output "gcp_frontend_url" {
  description = "URL of the GCP Cloud Run frontend service"
  value       = var.deploy_to_gcp ? module.gcp_infrastructure[0].frontend_url : null
}

output "gcp_backend_service_name" {
  description = "Name of the GCP backend Cloud Run service"
  value       = var.deploy_to_gcp ? module.gcp_infrastructure[0].backend_service_name : null
}

output "gcp_frontend_service_name" {
  description = "Name of the GCP frontend Cloud Run service"
  value       = var.deploy_to_gcp ? module.gcp_infrastructure[0].frontend_service_name : null
}

# Summary Output
output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    aws_deployed = var.deploy_to_aws
    gcp_deployed = var.deploy_to_gcp
    environment  = var.environment
    project_name = var.project_name
  }
}
