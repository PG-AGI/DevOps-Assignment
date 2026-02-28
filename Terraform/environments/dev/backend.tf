terraform {
  backend "s3" {
    bucket         = "shamitha-0924"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}