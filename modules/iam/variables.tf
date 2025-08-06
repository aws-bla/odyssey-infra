variable "company" {
  description = "Company name for resource naming"
  type        = string
}

variable "project" {
  description = "Project name for resource naming"
  type        = string
}



variable "secrets_arn" {
  description = "ARN of the Secrets Manager secret"
  type        = string
}



variable "input_bucket_arn" {
  description = "ARN of the input S3 bucket"
  type        = string
}

variable "output_bucket_arn" {
  description = "ARN of the output S3 bucket"
  type        = string
}

variable "kb_secrets_arn" {
  description = "ARN of the Knowledge Base secrets"
  type        = string
}