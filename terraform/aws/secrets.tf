# -----------------------
# Secrets Manager Secret
# -----------------------
resource "aws_secretsmanager_secret" "app_secret" {
  name = "devops/backend/app-secret"

  tags = {
    Name = "devops-backend-secret"
  }
}

# -----------------------
# Secret Value
# -----------------------
resource "aws_secretsmanager_secret_version" "app_secret_value" {
  secret_id     = aws_secretsmanager_secret.app_secret.id
  secret_string = var.app_secret_value
}

