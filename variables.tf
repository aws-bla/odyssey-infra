variable "company" {
  description = "Company name for resource naming"
  type        = string
  default     = "bla"
}

variable "project" {
  description = "Project name for resource naming"
  type        = string
  default     = "odyssey"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}



variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Domain variables removed - using default CloudFront and ALB DNS names

variable "github_owner" {
  description = "GitHub repository owner/organization"
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
  default     = "main"
}

variable "knowledge_base_id" {
  description = "Knowledge Base ID for cross-account access"
  type        = string
  default     = "WFO99DODD7"
}



