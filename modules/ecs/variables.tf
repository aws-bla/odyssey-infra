variable "company" {
  description = "Company name for resource naming"
  type        = string
}

variable "project" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "backend_ecr_url" {
  description = "Backend ECR repository URL"
  type        = string
}

variable "ai_ecr_url" {
  description = "AI ECR repository URL"
  type        = string
}

variable "backend_target_group_arn" {
  description = "Backend target group ARN"
  type        = string
}

variable "ai_target_group_arn" {
  description = "AI target group ARN"
  type        = string
}

variable "secrets_arn" {
  description = "Secrets Manager ARN"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "ai_internal_dns" {
  description = "AI service internal DNS name"
  type        = string
}

variable "backend_ecs_security_group_id" {
  description = "Backend ECS security group ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "input_bucket_name" {
  description = "Name of the input S3 bucket"
  type        = string
}

variable "output_bucket_name" {
  description = "Name of the output S3 bucket"
  type        = string
}

variable "kb_secrets_arn" {
  description = "ARN of the Knowledge Base secrets"
  type        = string
}

variable "knowledge_base_id" {
  description = "Knowledge Base ID"
  type        = string
}

variable "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  type        = string
}