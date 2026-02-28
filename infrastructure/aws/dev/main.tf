provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "dev_instance" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  tags = {
    Environment = "dev"
  }
}
