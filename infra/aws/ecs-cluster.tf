resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"
}
