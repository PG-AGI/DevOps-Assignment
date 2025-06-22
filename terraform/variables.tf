variable "aws_region" {
  default = "us-east-1"  # change if needed
}

variable "ecr_repos" {
  type    = list(string)
  default = ["backend", "frontend"]
}

