locals {
  base_name = "${var.company}-${var.project}-${terraform.workspace}"
}

# GitHub connection for CodePipeline
resource "aws_codestarconnections_connection" "github" {
  name          = "${local.base_name}-gh-conn"
  provider_type = "GitHub"

  tags = {
    Name        = "${local.base_name}-gh-conn"
    Environment = terraform.workspace
  }
}

# Frontend Pipeline
resource "aws_codepipeline" "frontend" {
  name     = "${local.base_name}-frontend-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = var.frontend_build_project_name
      }
    }
  }

  tags = {
    Name        = "${local.base_name}-frontend-pipeline"
    Environment = terraform.workspace
  }
}

# Backend Pipeline
resource "aws_codepipeline" "backend" {
  name     = "${local.base_name}-backend-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_owner}/${var.github_services_repo}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = var.backend_build_project_name
      }
    }
  }

  tags = {
    Name        = "${local.base_name}-backend-pipeline"
    Environment = terraform.workspace
  }
}

# AI Service Pipeline
resource "aws_codepipeline" "ai" {
  name     = "${local.base_name}-ai-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_owner}/${var.github_services_repo}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = var.ai_build_project_name
      }
    }
  }

  tags = {
    Name        = "${local.base_name}-ai-pipeline"
    Environment = terraform.workspace
  }
}