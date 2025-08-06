output "backend_target_group_arn" {
  description = "Backend target group ARN"
  value       = aws_lb_target_group.backend.arn
}

output "ai_internal_target_group_arn" {
  description = "AI internal target group ARN"
  value       = aws_lb_target_group.ai_internal.arn
}

output "backend_dns_name" {
  description = "Backend ALB DNS name"
  value       = aws_lb.backend.dns_name
}

output "ai_internal_dns_name" {
  description = "AI internal ALB DNS name"
  value       = aws_lb.ai_internal.dns_name
}

output "backend_ecs_security_group_id" {
  description = "Backend ECS security group ID"
  value       = aws_security_group.backend_ecs.id
}

output "ai_internal_security_group_id" {
  description = "AI internal security group ID"
  value       = aws_security_group.ai_internal.id
}