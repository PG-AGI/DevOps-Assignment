resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name  = "frontend"
      image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/frontend:${var.image_tag}"
      portMappings = [{
        containerPort = 3000
      }]
      environment = [
        {
          name  = "NEXT_PUBLIC_API_URL"
          value = "/api"
        }
      ]
      essential = true
    }
  ])
}
