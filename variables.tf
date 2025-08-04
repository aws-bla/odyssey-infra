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

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}