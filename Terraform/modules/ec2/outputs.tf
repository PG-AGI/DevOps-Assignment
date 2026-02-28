output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "Public IP of EC2"
  value       = aws_instance.main.public_ip
}

output "private_ip" {
  description = "Private IP of EC2"
  value       = aws_instance.main.private_ip
}