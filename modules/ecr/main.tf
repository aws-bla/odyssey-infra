locals {
  base_name = "${var.company}-${var.project}-${terraform.workspace}"
}

# Backend ECR Repository
resource "aws_ecr_repository" "backend" {
  name                 = "${local.base_name}-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${local.base_name}-backend"
    Environment = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "backend" {
  repository = aws_ecr_repository.backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# AI Service ECR Repository
resource "aws_ecr_repository" "ai" {
  name                 = "${local.base_name}-ai"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${local.base_name}-ai"
    Environment = var.environment
  }
}

resource "aws_ecr_lifecycle_policy" "ai" {
  repository = aws_ecr_repository.ai.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}