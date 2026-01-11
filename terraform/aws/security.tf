# Security Group for frontend
resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Allow public access to frontend"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Public access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for backend
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Allow only frontend access to backend"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]  # Only frontend can talk
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

