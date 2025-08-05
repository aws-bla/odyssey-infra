output "github_connection_arn" {
  description = "GitHub CodeStar connection ARN"
  value       = aws_codestarconnections_connection.github.arn
}

output "frontend_pipeline_name" {
  description = "Frontend pipeline name"
  value       = aws_codepipeline.frontend.name
}

output "backend_pipeline_name" {
  description = "Backend pipeline name"
  value       = aws_codepipeline.backend.name
}

output "ai_pipeline_name" {
  description = "AI pipeline name"
  value       = aws_codepipeline.ai.name
}