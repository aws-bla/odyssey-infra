output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.main.arn
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "codepipeline_role_arn" {
  description = "ARN of the CodePipeline role"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild role"
  value       = aws_iam_role.codebuild_role.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.main.name
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = aws_iam_instance_profile.main.name
}