# ------------------------------------------------------------------------------
# Django Health Metrics API Outputs
# ------------------------------------------------------------------------------

output "service_name" {
  description = "Name of the ECS service"
  value       = module.service.service_name
}

output "service_url" {
  description = "URL to access the API"
  value       = "http://${data.terraform_remote_state.shared.outputs.alb_dns_name}/api/v1/"
}

output "admin_url" {
  description = "URL to access Django admin"
  value       = "http://${data.terraform_remote_state.shared.outputs.alb_dns_name}/admin/"
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.service.task_definition_arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.service.log_group_name
}

output "database_endpoint" {
  description = "RDS database endpoint (if enabled)"
  value       = var.use_rds ? module.database[0].endpoint : "SQLite (embedded)"
}

output "database_connection_url" {
  description = "Database connection URL (sensitive)"
  value       = var.use_rds ? module.database[0].connection_url : var.database_url
  sensitive   = true
}
