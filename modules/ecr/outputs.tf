output "backend_repository_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "backend_repository_name" {
  description = "Backend ECR repository name"
  value       = aws_ecr_repository.backend.name
}

output "ai_repository_url" {
  description = "AI ECR repository URL"
  value       = aws_ecr_repository.ai.repository_url
}

output "ai_repository_name" {
  description = "AI ECR repository name"
  value       = aws_ecr_repository.ai.name
}