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

# Provider for ACM certificates (CloudFront requires us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

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

# Remove ACM module - no longer needed without custom domains

# Secrets Manager
module "secrets" {
  source = "./modules/secrets"

  company     = var.company
  project     = var.project
  environment = var.environment
}

module "iam" {
  source = "./modules/iam"

  company     = var.company
  project     = var.project
  component   = "iam"
  environment = var.environment
  secrets_arn = module.secrets.secrets_arn
}

# Frontend S3 and CloudFront
module "s3" {
  source = "./modules/s3"

  company     = var.company
  project     = var.project
  component   = "s3"
  bucket_name = "${local.base_name}-s3-frontend"
  environment = var.environment
}

module "cloudfront" {
  source = "./modules/cloudfront"

  company        = var.company
  project        = var.project
  environment    = var.environment
  s3_bucket_id   = module.s3.bucket_id
  s3_bucket_domain = module.s3.bucket_domain_name
}

# ECR for container images
module "ecr" {
  source = "./modules/ecr"

  company     = var.company
  project     = var.project
  environment = var.environment
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"

  company           = var.company
  project           = var.project
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}

# ECS Cluster and Services
module "ecs" {
  source = "./modules/ecs"

  company            = var.company
  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  backend_ecr_url    = module.ecr.backend_repository_url
  ai_ecr_url         = module.ecr.ai_repository_url
  backend_target_group_arn = module.alb.backend_target_group_arn
  ai_target_group_arn     = module.alb.ai_internal_target_group_arn
  secrets_arn        = module.secrets.secrets_arn
  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  ai_internal_dns    = module.alb.ai_internal_dns_name
  backend_ecs_security_group_id = module.alb.backend_ecs_security_group_id
}





# CodeBuild Projects
module "codebuild" {
  source = "./modules/codebuild"

  company                    = var.company
  project                    = var.project
  environment                = var.environment
  codebuild_role_arn         = module.iam.codebuild_role_arn
  frontend_bucket_name       = module.s3.bucket_name
  cloudfront_distribution_id = module.cloudfront.distribution_id
  backend_ecr_url            = module.ecr.backend_repository_url
  ai_ecr_url                 = module.ecr.ai_repository_url
  ecs_cluster_name           = module.ecs.cluster_name
  backend_service_name       = module.ecs.backend_service_name
  ai_service_name            = module.ecs.ai_service_name
}

# CodePipeline
module "codepipeline" {
  source = "./modules/codepipeline"

  company                      = var.company
  project                      = var.project
  environment                  = var.environment
  github_owner                 = var.github_owner
  github_repo                  = var.github_repo
  github_services_repo         = var.github_services_repo
  github_branch                = var.github_branch
  codepipeline_role_arn        = module.iam.codepipeline_role_arn
  artifacts_bucket_name        = module.codebuild.artifacts_bucket_name
  frontend_build_project_name  = module.codebuild.frontend_project_name
  backend_build_project_name   = module.codebuild.backend_project_name
  ai_build_project_name        = module.codebuild.ai_project_name
}