# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# Frontend Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket for frontend"
  value       = module.s3.bucket_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "frontend_cloudfront_domain" {
  description = "Frontend CloudFront default domain"
  value       = "https://${module.cloudfront.distribution_domain_name}"
}

# Backend Outputs
output "backend_alb_dns" {
  description = "Backend ALB DNS name"
  value       = "http://${module.alb.backend_dns_name}"
}

output "ai_internal_alb_dns" {
  description = "AI Service internal ALB DNS name"
  value       = "http://${module.alb.ai_internal_dns_name}"
}

# ECR Outputs
output "backend_ecr_repository_url" {
  description = "Backend ECR repository URL"
  value       = module.ecr.backend_repository_url
}

output "ai_ecr_repository_url" {
  description = "AI ECR repository URL"
  value       = module.ecr.ai_repository_url
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "backend_service_name" {
  description = "Backend ECS service name"
  value       = module.ecs.backend_service_name
}

output "ai_service_name" {
  description = "AI ECS service name"
  value       = module.ecs.ai_service_name
}

# IAM Outputs


# Secrets Manager
output "secrets_arn" {
  description = "Secrets Manager ARN"
  value       = module.secrets.secrets_arn
  sensitive   = true
}

output "current_workspace" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}

# CodePipeline Outputs
output "github_connection_arn" {
  description = "GitHub CodeStar connection ARN"
  value       = module.codepipeline.github_connection_arn
}

output "frontend_pipeline_name" {
  description = "Frontend pipeline name"
  value       = module.codepipeline.frontend_pipeline_name
}

output "backend_pipeline_name" {
  description = "Backend pipeline name"
  value       = module.codepipeline.backend_pipeline_name
}

output "ai_pipeline_name" {
  description = "AI pipeline name"
  value       = module.codepipeline.ai_pipeline_name
}