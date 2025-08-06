output "backend_repository_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "ai_repository_url" {
  description = "AI ECR repository URL"
  value       = aws_ecr_repository.ai.repository_url
}