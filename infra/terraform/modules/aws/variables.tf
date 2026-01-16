# AWS Module Variables

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "backend_image" {
  description = "Docker image for backend"
  type        = string
}

variable "frontend_image" {
  description = "Docker image for frontend"
  type        = string
}

variable "backend_cpu" {
  description = "CPU units for backend"
  type        = number
}

variable "backend_memory" {
  description = "Memory for backend"
  type        = number
}

variable "frontend_cpu" {
  description = "CPU units for frontend"
  type        = number
}

variable "frontend_memory" {
  description = "Memory for frontend"
  type        = number
}

variable "backend_port" {
  description = "Backend application port"
  type        = number
}

variable "frontend_port" {
  description = "Frontend application port"
  type        = number
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
}
