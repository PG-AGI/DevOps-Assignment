variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "devops-backend"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8000
}

variable "container_cpu" {
  description = "CPU units for container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for container (MB)"
  type        = number
  default     = 512
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alerts"
  type        = string
}

variable "app_secret_value" {
  description = "Secret value for backend (example)"
  type        = string
  sensitive   = true
}

