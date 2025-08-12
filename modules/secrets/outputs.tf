output "secrets_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "secrets_name" {
  description = "Name of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.app_secrets.name
}

output "kb_secrets_arn" {
  description = "ARN of the Knowledge Base secrets"
  value       = aws_secretsmanager_secret.kb_secrets.arn
}

output "kb_secrets_name" {
  description = "Name of the Knowledge Base secrets"
  value       = aws_secretsmanager_secret.kb_secrets.name
}





