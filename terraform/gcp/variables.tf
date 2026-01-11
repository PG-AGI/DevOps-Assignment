variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-north1"
}

variable "backend_image" {
  description = "Backend container image"
  type        = string
}

variable "frontend_image" {
  description = "Frontend container image"
  type        = string
}

variable "backend_secret_value" {
  description = "Backend secret value"
  type        = string
  sensitive   = true
}
variable "project_number" {
  description = "GCP project number"
  type        = string
}



