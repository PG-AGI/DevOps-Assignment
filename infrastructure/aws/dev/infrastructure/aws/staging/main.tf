provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "staging_instance" {
  ami           = "ami-12345678"
  instance_type = "t2.small"

  tags = {
    Name        = "staging-instance"
    Environment = "staging"
  }
}
