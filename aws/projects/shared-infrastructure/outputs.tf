# ------------------------------------------------------------------------------
# Shared Infrastructure Outputs
# These outputs are used by individual service deployments
# ------------------------------------------------------------------------------

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "availability_zones" {
  description = "Availability zones used"
  value       = module.vpc.availability_zones
}

# ECS Cluster Outputs
output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs_cluster.cluster_id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = module.ecs_cluster.task_execution_role_arn
}

output "ecs_tasks_security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = module.ecs_cluster.ecs_tasks_security_group_id
}

# ALB Outputs
output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.ecs_cluster.alb_arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.ecs_cluster.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB (for Route53)"
  value       = module.ecs_cluster.alb_zone_id
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = module.ecs_cluster.http_listener_arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = module.ecs_cluster.https_listener_arn
}

# Summary
output "summary" {
  description = "Quick reference for service deployments"
  value = {
    alb_url            = "http://${module.ecs_cluster.alb_dns_name}"
    cluster_name       = module.ecs_cluster.cluster_name
    private_subnet_ids = join(", ", module.vpc.private_subnet_ids)
  }
}
