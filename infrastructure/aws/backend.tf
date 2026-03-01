terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# State management - S3 with DynamoDB for locking
terraform {
  backend "s3" {
    bucket         = "devops-assignment-tf-state"
    key            = "aws/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "devops-assignment-tf-lock"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project         = "DevOps-Assignment"
      Environment     = var.environment
      ManagedBy       = "Terraform"
      Repository      = "github.com/user/devops-assignment"
    }
  }
}
