locals {
  base_name = "${var.company}-${var.project}-${terraform.workspace}"
}

# S3 bucket for CodeBuild artifacts
resource "aws_s3_bucket" "codebuild_artifacts" {
  bucket = "${local.base_name}-codebuild-artifacts"

  tags = {
    Name        = "${local.base_name}-codebuild-artifacts"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "codebuild_artifacts" {
  bucket = aws_s3_bucket.codebuild_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codebuild_artifacts" {
  bucket = aws_s3_bucket.codebuild_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Frontend CodeBuild Project
resource "aws_codebuild_project" "frontend" {
  name         = "${local.base_name}-frontend-build"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "S3_BUCKET"
      value = var.frontend_bucket_name
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = var.cloudfront_distribution_id
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec-frontend.yml"
  }

  tags = {
    Name        = "${local.base_name}-frontend-build"
    Environment = var.environment
  }
}

# Backend CodeBuild Project
resource "aws_codebuild_project" "backend" {
  name         = "${local.base_name}-backend-build"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                       = "LINUX_CONTAINER"
    privileged_mode            = true

    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = var.backend_ecr_url
    }

    environment_variable {
      name  = "ECS_CLUSTER_NAME"
      value = var.ecs_cluster_name
    }

    environment_variable {
      name  = "ECS_SERVICE_NAME"
      value = var.backend_service_name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec-backend.yml"
  }

  tags = {
    Name        = "${local.base_name}-backend-build"
    Environment = var.environment
  }
}

# AI Service CodeBuild Project
resource "aws_codebuild_project" "ai" {
  name         = "${local.base_name}-ai-build"
  service_role = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                      = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                       = "LINUX_CONTAINER"
    privileged_mode            = true

    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = var.ai_ecr_url
    }

    environment_variable {
      name  = "ECS_CLUSTER_NAME"
      value = var.ecs_cluster_name
    }

    environment_variable {
      name  = "ECS_SERVICE_NAME"
      value = var.ai_service_name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec-ai.yml"
  }

  tags = {
    Name        = "${local.base_name}-ai-build"
    Environment = var.environment
  }
}