# ------------------------------------------------------------------------------
# Audit Log Aggregator Outputs
# ------------------------------------------------------------------------------

output "service_name" {
  description = "Name of the ECS service"
  value       = module.service.service_name
}

output "service_url" {
  description = "URL to access the service"
  value       = "http://${data.terraform_remote_state.shared.outputs.alb_dns_name}/audit"
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.service.task_definition_arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.service.log_group_name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = module.service.target_group_arn
}
