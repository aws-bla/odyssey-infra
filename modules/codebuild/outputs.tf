output "frontend_project_name" {
  description = "Frontend CodeBuild project name"
  value       = aws_codebuild_project.frontend.name
}

output "backend_project_name" {
  description = "Backend CodeBuild project name"
  value       = aws_codebuild_project.backend.name
}

output "ai_project_name" {
  description = "AI CodeBuild project name"
  value       = aws_codebuild_project.ai.name
}

output "artifacts_bucket_name" {
  description = "CodeBuild artifacts S3 bucket name"
  value       = aws_s3_bucket.codebuild_artifacts.bucket
}