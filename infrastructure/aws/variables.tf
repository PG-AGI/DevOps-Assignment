variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "devops-assignment"
}

# Frontend configuration
variable "frontend_container_port" {
  description = "Port for frontend container"
  type        = number
  default     = 3000
}

# Backend configuration
variable "backend_container_port" {
  description = "Port for backend container"
  type        = number
  default     = 8000
}

# Scaling configuration
variable "backend_min_capacity" {
  description = "Minimum number of backend tasks"
  type        = number
  default     = 1
}

variable "backend_max_capacity" {
  description = "Maximum number of backend tasks"
  type        = number
  default     = 4
}

variable "frontend_min_capacity" {
  description = "Minimum number of frontend tasks"
  type        = number
  default     = 1
}

variable "frontend_max_capacity" {
  description = "Maximum number of frontend tasks"
  type        = number
  default     = 4
}

# Instance type for ECS (if using EC2)
variable "instance_type" {
  description = "ECS instance type"
  type        = string
  default     = "t3.small"
}

# ACM Certificate ARN (for HTTPS)
variable "certificate_arn" {
  description = "ACM Certificate ARN for HTTPS"
  type        = string
  default     = ""
}

# Domain names (optional)
variable "backend_domain" {
  description = "Backend custom domain"
  type        = string
  default     = ""
}

variable "frontend_domain" {
  description = "Frontend custom domain"
  type        = string
  default     = ""
}
