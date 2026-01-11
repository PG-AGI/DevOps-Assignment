resource "aws_ecs_task_definition" "backend" {
  family                   = "backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/backend:${var.image_tag}"
      portMappings = [{
        containerPort = 8000
      }]
      essential = true
    }
  ])
}
