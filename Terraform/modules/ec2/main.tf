resource "aws_instance" "main" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  iam_instance_profile = var.instance_profile

  tags = {
    Name = "Terraform-EC2"
  }
}