variable "company" {
  description = "Company name for resource naming"
  type        = string
}

variable "project" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_services_repo" {
  description = "GitHub services repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to track"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "CodePipeline service role ARN"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "S3 bucket for pipeline artifacts"
  type        = string
}

variable "frontend_build_project_name" {
  description = "Frontend CodeBuild project name"
  type        = string
}

variable "backend_build_project_name" {
  description = "Backend CodeBuild project name"
  type        = string
}

variable "ai_build_project_name" {
  description = "AI CodeBuild project name"
  type        = string
}