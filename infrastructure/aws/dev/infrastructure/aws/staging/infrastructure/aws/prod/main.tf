provider "aws" {
  region = "ap-south-1"
}

resource "aws_launch_template" "prod_template" {
  name_prefix   = "prod-template"
  image_id      = "ami-12345678"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "prod_asg" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  vpc_zone_identifier  = ["subnet-123456"]

  launch_template {
    id      = aws_launch_template.prod_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Environment"
    value               = "prod"
    propagate_at_launch = true
  }
}
