variable "backend_image" {
  description = "Backend Docker image from ECR"
}
variable "frontend_image" {
  description = "Frontend Docker image from ECR"
  type        = string
}

