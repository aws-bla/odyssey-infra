locals {
  base_name = "${var.company}-${var.project}-${terraform.workspace}"
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${local.base_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow traffic to backend ECS tasks"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name        = "${local.base_name}-alb-sg"
    Environment = var.environment
  }
}

# Backend ALB
resource "aws_lb" "backend" {
  name               = "${local.base_name}-be-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${local.base_name}-backend-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "backend" {
  name        = "${local.base_name}-be-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${local.base_name}-backend-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "backend_http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# Internal AI Service ALB
resource "aws_security_group" "ai_internal" {
  name        = "${local.base_name}-ai-internal-sg"
  description = "Security group for internal AI service ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_ecs.id]
  }

  egress {
    description = "Allow traffic to AI ECS tasks"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name        = "${local.base_name}-ai-internal-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "backend_ecs" {
  name        = "${local.base_name}-backend-ecs-sg"
  description = "Security group for backend ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5000
    to_port     = 5000
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

  egress {
    description = "HTTP for AI service communication"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name        = "${local.base_name}-backend-ecs-sg"
    Environment = var.environment
  }
}

resource "aws_lb" "ai_internal" {
  name               = "${local.base_name}-ai-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ai_internal.id]
  subnets            = var.private_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${local.base_name}-ai-internal-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "ai_internal" {
  name        = "${local.base_name}-ai-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${local.base_name}-ai-internal-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "ai_internal" {
  load_balancer_arn = aws_lb.ai_internal.arn
  port              = "8000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ai_internal.arn
  }
}