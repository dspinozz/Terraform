# ------------------------------------------------------------------------------
# ECS Service Module Outputs
# ------------------------------------------------------------------------------

output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.main.id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.main.name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.main.id
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.main.arn
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = aws_ecs_task_definition.main.family
}

output "task_definition_revision" {
  description = "Revision of the task definition"
  value       = aws_ecs_task_definition.main.revision
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = var.create_alb_target_group ? aws_lb_target_group.main[0].arn : null
}

output "target_group_name" {
  description = "Name of the ALB target group"
  value       = var.create_alb_target_group ? aws_lb_target_group.main[0].name : null
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.arn
}

output "container_name" {
  description = "Name of the container"
  value       = local.container_name
}

output "container_port" {
  description = "Port of the container"
  value       = var.container_port
}
