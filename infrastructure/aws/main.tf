#==============================================================================
# AWS Infrastructure for DevOps Assignment
# Region: us-east-1 (Justification: Low latency for US East coast, lowest cost)
# Compute: ECS Fargate (Justification: Managed containers, auto-scaling, no server management)
#==============================================================================

#==============================================================================
# VPC and Networking
#==============================================================================
resource "aws_vpc" "main" {
  cidr_block           = var.environment == "prod" ? "10.0.0.0/16" : "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.app_name}-${var.environment}-vpc"
  }
}

# Public Subnets (for ALB and NAT Gateway)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.environment == "prod" ? "10.0.${count.index + 1}.0/24" : "172.16.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.app_name}-${var.environment}-public-${count.index + 1}"
    Type = "Public"
  }
}

# Private Subnets (for ECS tasks)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.environment == "prod" ? "10.0.${count.index + 10}.0/24" : "172.16.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "${var.app_name}-${var.environment}-private-${count.index + 1}"
    Type = "Private"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.app_name}-${var.environment}-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = {
    Name = "${var.app_name}-${var.environment}-nat-eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  
  tags = {
    Name = "${var.app_name}-${var.environment}-nat"
  }
  
  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "${var.app_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table (with NAT for outbound)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  
  tags = {
    Name = "${var.app_name}-${var.environment}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count].id
  route_table_id = aws_route_table.private.id
}

#==============================================================================
# Security Groups
#==============================================================================

# ALB Security Group (Public)
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.app_name}-${var.environment}-alb-sg"
  }
}

# Backend ECS Security Group (Private)
resource "aws_security_group" "backend" {
  name        = "${var.app_name}-${var.environment}-backend-sg"
  description = "Security group for backend ECS tasks"
  vpc_id      = aws_vpc.main.id
  
  # Allow traffic from ALB
  ingress {
    description     = "Traffic from ALB"
    from_port       = var.backend_container_port
    to_port         = var.backend_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  # Allow traffic from frontend (for CORS)
  ingress {
    description = "HTTPS anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.app_name}-${var.environment}-backend-sg"
  }
}

# Frontend ECS Security Group (Private)
resource "aws_security_group" "frontend" {
  name        = "${var.app_name}-${var.environment}-frontend-sg"
  description = "Security group for frontend ECS tasks"
  vpc_id      = aws_vpc.main.id
  
  # Allow traffic from ALB
  ingress {
    description     = "Traffic from ALB"
    from_port       = var.frontend_container_port
    to_port         = var.frontend_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.app_name}-${var.environment}-frontend-sg"
  }
}

#==============================================================================
# ECS Cluster
#==============================================================================
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-${var.environment}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Name = "${var.app_name}-${var.environment}-ecs-cluster"
  }
}

#==============================================================================
# IAM Roles for ECS Tasks
#==============================================================================

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-${var.environment}-ecs-task-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (for accessing secrets)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.app_name}-${var.environment}-ecs-task-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Allow ECS task to read secrets
resource "aws_iam_role_policy" "ecs_task_secrets_policy" {
  name = "${var.app_name}-${var.environment}-ecs-secrets-policy"
  role = aws_iam_role.ecs_task_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = "arn:aws:secretsmanager:*:*:secret:${var.app_name}/*"
    }]
  })
}

#==============================================================================
# Application Load Balancer
#==============================================================================
resource "aws_lb" "main" {
  name               = "${var.app_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  
  enable_deletion_protection = var.environment == "prod" ? true : false
  
  tags = {
    Name = "${var.app_name}-${var.environment}-alb"
  }
}

# Target Groups
resource "aws_lb_target_group" "backend" {
  name     = "${var.app_name}-${var.environment}-backend-tg"
  port     = var.backend_container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  
  tags = {
    Name = "${var.app_name}-${var.environment}-backend-tg"
  }
}

resource "aws_lb_target_group" "frontend" {
  name     = "${var.app_name}-${var.environment}-frontend-tg"
  port     = var.frontend_container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  
  tags = {
    Name = "${var.app_name}-${var.environment}-frontend-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# ALB Listener Rule for backend (path-based routing)
resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.frontend.arn
  priority     = 100
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

#==============================================================================
# ECS Services and Task Definitions
#==============================================================================

# Backend Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.app_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.environment == "prod" ? "512" : "256"
  memory                   = var.environment == "prod" ? "1024" : "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "backend"
      image        = "${local.backend_image}:${var.environment}"
      essential    = true
      portMappings = [
        {
          containerPort = var.backend_container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        }
      ]
      secrets = [
        {
          name      = "API_URL"
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${local.aws_account_id}:secret:${var.app_name}/backend-api-url"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}-backend-${var.environment}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  
  tags = {
    Name = "${var.app_name}-backend-taskdef"
  }
}

# Backend ECS Service
resource "aws_ecs_service" "backend" {
  name            = "${var.app_name}-backend-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.environment == "prod" ? 2 : 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.backend.id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = var.backend_container_port
  }
  
  deployment_controller {
    type = "ECS"
  }
  
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  
  depends_on = [aws_lb_listener_rule.backend]
  
  tags = {
    Name = "${var.app_name}-backend-service"
  }
}

# Frontend Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.app_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.environment == "prod" ? "512" : "256"
  memory                   = var.environment == "prod" ? "1024" : "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "frontend"
      image        = "${local.frontend_image}:${var.environment}"
      essential    = true
      portMappings = [
        {
          containerPort = var.frontend_container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "NEXT_PUBLIC_API_URL"
          value = "http://${aws_lb.main.dns_name}/api"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}-frontend-${var.environment}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  
  tags = {
    Name = "${var.app_name}-frontend-taskdef"
  }
}

# Frontend ECS Service
resource "aws_ecs_service" "frontend" {
  name            = "${var.app_name}-frontend-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.environment == "prod" ? 2 : 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.frontend.id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = var.frontend_container_port
  }
  
  deployment_controller {
    type = "ECS"
  }
  
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  
  depends_on = [aws_lb_listener.frontend]
  
  tags = {
    Name = "${var.app_name}-frontend-service"
  }
}

#==============================================================================
# Auto Scaling
#==============================================================================

# ECS Service Auto Scaling Role
resource "aws_iam_role" "ecs_scaling_role" {
  name = "${var.app_name}-${var.environment}-ecs-scaling-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "application-autoscaling.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_scaling_role_policy" {
  role       = aws_iam_role.ecs_scaling_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSServiceAutoScalingRole"
}

# Backend Auto Scaling Target
resource "aws_appautoscaling_target" "backend" {
  max_capacity       = var.backend_max_capacity
  min_capacity       = var.backend_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.backend.name}"
  role_arn           = aws_iam_role.ecs_scaling_role.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Backend CPU Auto Scaling Policy
resource "aws_appautoscaling_policy" "backend_cpu" {
  name               = "${var.app_name}-backend-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend.resource_id
  scalable_dimension = aws_appautoscaling_target.backend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend.service_namespace
  
  target_value = 70.0
  
  predefined_metric_specification {
    predefined_metric_type = "ECSServiceAverageCPUUtilization"
  }
}

# Backend Request Count Auto Scaling Policy
resource "aws_appautoscaling_policy" "backend_requests" {
  name               = "${var.app_name}-backend-request-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend.resource_id
  scalable_dimension = aws_appautoscaling_target.backend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend.service_namespace
  
  target_value = 1000.0
  
  predefined_metric_specification {
    predefined_metric_type = "ALBRequestCountPerTarget"
    resource_label          = "${aws_lb.main.arn_suffix}/${aws_lb_target_group.backend.arn_suffix}"
  }
}

#==============================================================================
# CloudWatch Logs
#==============================================================================
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.app_name}-backend-${var.environment}"
  retention_in_days = var.environment == "prod" ? 30 : 7
  
  tags = {
    Name = "${var.app_name}-backend-logs"
  }
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.app_name}-frontend-${var.environment}"
  retention_in_days = var.environment == "prod" ? 30 : 7
  
  tags = {
    Name = "${var.app_name}-frontend-logs"
  }
}

#==============================================================================
# Secrets Manager
#==============================================================================
resource "aws_secretsmanager_secret" "backend_api_url" {
  name        = "${var.app_name}/backend-api-url"
  description = "Backend API URL for frontend"
  
  recovery_window_in_days = 0  # Immediate deletion for non-prod
  
  tags = {
    Name = "${var.app_name}-backend-api-url-secret"
  }
}

resource "aws_secretsmanager_secret_version" "backend_api_url" {
  secret_id = aws_secretsmanager_secret.backend_api_url.id
  secret_string = jsonencode({
    api_url = "http://${aws_lb.main.dns_name}/api"
  })
}

#==============================================================================
# Data Sources
#==============================================================================
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  backend_image  = "${local.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/devops-backend"
  frontend_image = "${local.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/devops-frontend"
}

#==============================================================================
# Outputs
#==============================================================================
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB Zone ID"
  value       = aws_lb.main.zone_id
}

output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.main.name
}

output "backend_service_name" {
  description = "Backend ECS Service Name"
  value       = aws_ecs_service.backend.name
}

output "frontend_service_name" {
  description = "Frontend ECS Service Name"
  value       = aws_ecs_service.frontend.name
}
