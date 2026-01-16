# Global Variables

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "pg-agi"
}

variable "deploy_to_aws" {
  description = "Whether to deploy AWS infrastructure"
  type        = bool
  default     = true
}

variable "deploy_to_gcp" {
  description = "Whether to deploy GCP infrastructure"
  type        = bool
  default     = true
}

# AWS Variables

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_availability_zones" {
  description = "List of availability zones for AWS deployment"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "backend_image_aws" {
  description = "Docker image for backend on AWS ECR"
  type        = string
  default     = "latest" # Will be replaced with actual ECR URL
}

variable "frontend_image_aws" {
  description = "Docker image for frontend on AWS ECR"
  type        = string
  default     = "latest" # Will be replaced with actual ECR URL
}

# GCP Variables

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for deployment"
  type        = string
  default     = "us-central1"
}

variable "backend_image_gcp" {
  description = "Docker image for backend on GCP GCR"
  type        = string
  default     = "latest" # Will be replaced with actual GCR URL
}

variable "frontend_image_gcp" {
  description = "Docker image for frontend on GCP GCR"
  type        = string
  default     = "latest" # Will be replaced with actual GCR URL
}

variable "gcp_min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 1
}

variable "gcp_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10
}

variable "gcp_cpu_limit" {
  description = "CPU limit for Cloud Run services"
  type        = string
  default     = "1"
}

variable "gcp_memory_limit" {
  description = "Memory limit for Cloud Run services"
  type        = string
  default     = "512Mi"
}

# Application Configuration

variable "backend_cpu" {
  description = "CPU units for backend container (AWS)"
  type        = number
  default     = 512
}

variable "backend_memory" {
  description = "Memory (MB) for backend container (AWS)"
  type        = number
  default     = 1024
}

variable "frontend_cpu" {
  description = "CPU units for frontend container (AWS)"
  type        = number
  default     = 512
}

variable "frontend_memory" {
  description = "Memory (MB) for frontend container (AWS)"
  type        = number
  default     = 1024
}

variable "backend_port" {
  description = "Port on which backend application runs"
  type        = number
  default     = 8000
}

variable "frontend_port" {
  description = "Port on which frontend application runs"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "Health check path for backend"
  type        = string
  default     = "/health"
}

variable "desired_count" {
  description = "Desired number of tasks to run"
  type        = number
  default     = 2
}
