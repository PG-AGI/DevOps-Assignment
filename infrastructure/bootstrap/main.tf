#==============================================================================
# Bootstrap Terraform Configuration
# This creates the S3 bucket and DynamoDB table for Terraform state management
# Run this first before deploying the main infrastructure
#==============================================================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#==============================================================================
# S3 Bucket for Terraform State
#==============================================================================
resource "aws_s3_bucket" "tf_state" {
  bucket = "devops-assignment-tf-state"
  
  tags = {
    Name        = "devops-assignment-tf-state"
    Environment = "bootstrap"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#==============================================================================
# DynamoDB Table for State Locking
#==============================================================================
resource "aws_dynamodb_table" "tf_lock" {
  name         = "devops-assignment-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = {
    Name        = "devops-assignment-tf-lock"
    Environment = "bootstrap"
  }
}

#==============================================================================
# Outputs
#==============================================================================
output "s3_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.tf_state.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  value       = aws_dynamodb_table.tf_lock.name
}
