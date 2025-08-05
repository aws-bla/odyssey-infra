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

variable "environment" {
  description = "Environment/workspace name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "bla-odyssey-dev-terraform-state-811829856208"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "bla-odyssey-dev-terraform-lock"
}