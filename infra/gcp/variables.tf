variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag (Git SHA)"
}
