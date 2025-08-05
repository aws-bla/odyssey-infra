locals {
  base_name = "${var.company}-${var.project}-${terraform.workspace}"
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${local.base_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${local.base_name}-cluster"
    Environment = var.environment
  }
}

# Security Group for AI ECS Tasks
resource "aws_security_group" "ai_ecs_tasks" {
  name        = "${local.base_name}-ai-ecs-tasks-sg"
  description = "Security group for AI ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "HTTPS for external APIs and AWS services"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.base_name}-ai-ecs-tasks-sg"
    Environment = var.environment
  }
}

# Backend Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${local.base_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  task_role_arn           = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "${var.backend_ecr_url}:latest"
      
      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]

      secrets = [
        {
          name      = "SECRETS"
          valueFrom = var.secrets_arn
        }
      ]

      environment = [
        {
          name  = "PORT"
          value = "5000"
        },
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "AI_SERVICE_URL"
          value = "http://${var.ai_internal_dns}:8000"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      essential = true
    }
  ])

  tags = {
    Name        = "${local.base_name}-backend-task"
    Environment = var.environment
  }
}

# Backend Service
resource "aws_ecs_service" "backend" {
  name            = "${local.base_name}-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [var.backend_ecs_security_group_id]
    subnets         = var.private_subnet_ids
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = "backend"
    container_port   = 5000
  }

  depends_on = [var.backend_target_group_arn]

  tags = {
    Name        = "${local.base_name}-backend-service"
    Environment = var.environment
  }
}

# AI Task Definition
resource "aws_ecs_task_definition" "ai" {
  family                   = "${local.base_name}-ai"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = var.execution_role_arn
  task_role_arn           = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "ai"
      image = "${var.ai_ecr_url}:latest"
      
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]

      secrets = [
        {
          name      = "SECRETS"
          valueFrom = var.secrets_arn
        }
      ]

      environment = [
        {
          name  = "PORT"
          value = "8000"
        },
        {
          name  = "ENVIRONMENT"
          value = "production"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ai.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      essential = true
    }
  ])

  tags = {
    Name        = "${local.base_name}-ai-task"
    Environment = var.environment
  }
}

# AI Service
resource "aws_ecs_service" "ai" {
  name            = "${local.base_name}-ai-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ai.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ai_ecs_tasks.id]
    subnets         = var.private_subnet_ids
  }

  load_balancer {
    target_group_arn = var.ai_target_group_arn
    container_name   = "ai"
    container_port   = 8000
  }

  depends_on = [var.ai_target_group_arn]

  tags = {
    Name        = "${local.base_name}-ai-service"
    Environment = var.environment
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${local.base_name}-backend"
  retention_in_days = 7

  tags = {
    Name        = "${local.base_name}-backend-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "ai" {
  name              = "/ecs/${local.base_name}-ai"
  retention_in_days = 7

  tags = {
    Name        = "${local.base_name}-ai-logs"
    Environment = var.environment
  }
}

data "aws_region" "current" {}

