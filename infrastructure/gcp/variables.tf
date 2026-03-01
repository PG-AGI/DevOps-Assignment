variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "my-project-devops-488902"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
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

# Backend configuration
variable "backend_min_instances" {
  description = "Minimum Cloud Run instances for backend"
  type        = number
  default     = 1
}

variable "backend_max_instances" {
  description = "Maximum Cloud Run instances for backend"
  type        = number
  default     = 10
}

variable "backend_memory" {
  description = "Backend memory in Mi"
  type        = string
  default     = "512Mi"
}

variable "backend_cpu" {
  description = "Backend CPU allocation"
  type        = string
  default     = "1"
}

# Frontend configuration
variable "frontend_min_instances" {
  description = "Minimum Cloud Run instances for frontend"
  type        = number
  default     = 1
}

variable "frontend_max_instances" {
  description = "Maximum Cloud Run instances for frontend"
  type        = number
  default     = 10
}

variable "frontend_memory" {
  description = "Frontend memory in Mi"
  type        = string
  default     = "512Mi"
}

variable "frontend_cpu" {
  description = "Frontend CPU allocation"
  type        = string
  default     = "1"
}

# Concurrency
variable "cloud_run_concurrency" {
  description = "Max concurrent requests per instance"
  type        = number
  default     = 80
}
