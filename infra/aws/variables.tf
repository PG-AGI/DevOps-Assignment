variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default = "devops-assigment"
}

variable "image_tag" {
  description = "Docker image tag (Git SHA)"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}
