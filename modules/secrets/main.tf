locals {
  base_name = "${var.company}-${var.project}-${terraform.workspace}"
}

resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "${local.base_name}-app-secrets"
  description = "Application secrets for ${var.project}"

  tags = {
    Name        = "${local.base_name}-app-secrets"
    Environment = terraform.workspace
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

# Knowledge Base Secrets for cross-account access
resource "aws_secretsmanager_secret" "kb_secrets" {
  name        = "${local.base_name}-kb-credentials"
  description = "Knowledge Base AWS credentials for cross-account access"

  tags = {
    Name        = "${local.base_name}-kb-secrets"
    Environment = terraform.workspace
  }
}

resource "aws_secretsmanager_secret_version" "kb_secrets" {
  secret_id = aws_secretsmanager_secret.kb_secrets.id
  secret_string = jsonencode({
    AWS_ACCESS_KEY_ID     = "placeholder-access-key-id"
    AWS_SECRET_ACCESS_KEY = "placeholder-secret-access-key"
    AWS_DEFAULT_REGION    = "us-west-2"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}