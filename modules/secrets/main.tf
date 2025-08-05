locals {
  base_name = "${var.company}-${var.project}-${terraform.workspace}"
}

resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${local.base_name}-app-secrets"
  description = "Application secrets for ${var.project}"

  tags = {
    Name        = "${local.base_name}-app-secrets"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    database_url = "postgresql://user:password@localhost:5432/dbname"
    api_key      = "your-api-key-here"
    jwt_secret   = "your-jwt-secret-here"
    redis_url    = "redis://localhost:6379"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}