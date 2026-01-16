# Main Terraform Configuration
# This file orchestrates the infrastructure for both AWS and GCP

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Optional: Configure remote backend for state management
  # Uncomment and configure based on your needs
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "pg-agi/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "PG-AGI-DevOps"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# GCP Provider Configuration
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# AWS Infrastructure Module
module "aws_infrastructure" {
  source = "./modules/aws"

  count = var.deploy_to_aws ? 1 : 0

  environment        = var.environment
  project_name       = var.project_name
  aws_region         = var.aws_region
  vpc_cidr           = var.aws_vpc_cidr
  availability_zones = var.aws_availability_zones
  backend_image      = var.backend_image_aws
  frontend_image     = var.frontend_image_aws
  backend_cpu        = var.backend_cpu
  backend_memory     = var.backend_memory
  frontend_cpu       = var.frontend_cpu
  frontend_memory    = var.frontend_memory
  backend_port       = var.backend_port
  frontend_port      = var.frontend_port
  health_check_path  = var.health_check_path
  desired_count      = var.desired_count
}

# GCP Infrastructure Module
module "gcp_infrastructure" {
  source = "./modules/gcp"

  count = var.deploy_to_gcp ? 1 : 0

  environment    = var.environment
  project_name   = var.project_name
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  backend_image  = var.backend_image_gcp
  frontend_image = var.frontend_image_gcp
  backend_port   = var.backend_port
  frontend_port  = var.frontend_port
  min_instances  = var.gcp_min_instances
  max_instances  = var.gcp_max_instances
  cpu_limit      = var.gcp_cpu_limit
  memory_limit   = var.gcp_memory_limit
}
