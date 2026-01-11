resource "aws_ecs_cluster" "this" {
  name = "devops-assignment-cluster"
}
# main.tf
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "devops-vpc"
  }
}

# Public subnet for frontend
resource "aws_subnet" "public_frontend" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
  tags = { Name = "frontend-public-subnet" }
}

# Private subnet for backend
resource "aws_subnet" "private_backend" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1a"
  tags = { Name = "backend-private-subnet" }
}

# Internet Gateway for public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id
  tags   = { Name = "devops-igw" }
}

# Route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "frontend_assoc" {
  subnet_id      = aws_subnet.public_frontend.id
  route_table_id = aws_route_table.public_rt.id
}

