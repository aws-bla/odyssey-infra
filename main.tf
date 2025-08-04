terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  base_name = "${var.company}-${var.project}-${terraform.workspace}"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Company     = var.company
      Project     = var.project
      Environment = terraform.workspace
      ManagedBy   = "terraform"
      Workspace   = terraform.workspace
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  company     = var.company
  project     = var.project
  component   = "vpc"
  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

module "iam" {
  source = "./modules/iam"

  company     = var.company
  project     = var.project
  component   = "iam"
  environment = var.environment
}

module "s3" {
  source = "./modules/s3"

  company     = var.company
  project     = var.project
  component   = "s3"
  bucket_name = "${local.base_name}-s3-data"
  environment = var.environment
}