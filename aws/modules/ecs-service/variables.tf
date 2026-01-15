# ------------------------------------------------------------------------------
# ECS Service Module Variables
# ------------------------------------------------------------------------------

# Basic Configuration
variable "name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the service"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the service"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Container Configuration
variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "container_name" {
  description = "Name of the container (defaults to service name)"
  type        = string
  default     = ""
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu)
    error_message = "CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "memory" {
  description = "Memory (MB) for the task"
  type        = number
  default     = 512

  validation {
    condition     = var.memory >= 512 && var.memory <= 30720
    error_message = "Memory must be between 512 and 30720 MB."
  }
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets to inject (name = Secrets Manager ARN)"
  type        = map(string)
  default     = {}
}

variable "container_health_check" {
  description = "Container health check configuration"
  type = object({
    command      = list(string)
    interval     = number
    timeout      = number
    retries      = number
    start_period = number
  })
  default = null
}

# IAM Roles
variable "execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role (for application permissions)"
  type        = string
  default     = null
}

# Service Configuration
variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks"
  type        = bool
  default     = false
}

variable "use_capacity_provider_strategy" {
  description = "Use capacity provider strategy instead of launch type"
  type        = bool
  default     = true
}

variable "capacity_provider_strategy" {
  description = "Capacity provider strategy"
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = optional(number, 0)
  }))
  default = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
    }
  ]
}

# Deployment Configuration
variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent during deployment"
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "Maximum percent during deployment"
  type        = number
  default     = 200
}

variable "enable_circuit_breaker" {
  description = "Enable deployment circuit breaker"
  type        = bool
  default     = true
}

variable "enable_circuit_breaker_rollback" {
  description = "Enable automatic rollback on deployment failure"
  type        = bool
  default     = true
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging"
  type        = bool
  default     = false
}

# Load Balancer Configuration
variable "create_alb_target_group" {
  description = "Create ALB target group"
  type        = bool
  default     = true
}

variable "listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
  default     = ""
}

variable "listener_rule_priority" {
  description = "Priority for the listener rule (1-50000)"
  type        = number
  default     = 100
}

variable "host_headers" {
  description = "Host header values for routing"
  type        = list(string)
  default     = null
}

variable "path_patterns" {
  description = "Path patterns for routing"
  type        = list(string)
  default     = null
}

variable "deregistration_delay" {
  description = "Time to wait before deregistering targets"
  type        = number
  default     = 30
}

# Health Check Configuration
variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "health_check_matcher" {
  description = "HTTP codes for healthy response"
  type        = string
  default     = "200-299"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3
}

# Auto Scaling Configuration
variable "enable_autoscaling" {
  description = "Enable auto scaling"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 4
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization percentage"
  type        = number
  default     = 70
}

variable "autoscaling_memory_target" {
  description = "Target memory utilization percentage (optional)"
  type        = number
  default     = null
}

variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown period for scale in (seconds)"
  type        = number
  default     = 300
}

variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown period for scale out (seconds)"
  type        = number
  default     = 60
}

# Logging
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

# Tags
variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}
