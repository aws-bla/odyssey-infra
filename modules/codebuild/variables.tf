variable "company" {
  description = "Company name for resource naming"
  type        = string
}

variable "project" {
  description = "Project name for resource naming"
  type        = string
}



variable "codebuild_role_arn" {
  description = "CodeBuild service role ARN"
  type        = string
}

variable "frontend_bucket_name" {
  description = "Frontend S3 bucket name"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  type        = string
}

variable "backend_ecr_url" {
  description = "Backend ECR repository URL"
  type        = string
}

variable "ai_ecr_url" {
  description = "AI ECR repository URL"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "backend_service_name" {
  description = "Backend ECS service name"
  type        = string
}

variable "ai_service_name" {
  description = "AI ECS service name"
  type        = string
}

variable "backend_alb_dns" {
  description = "Backend ALB DNS name"
  type        = string
}