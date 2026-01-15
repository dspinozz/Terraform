# ------------------------------------------------------------------------------
# Employee Management API Variables
# ------------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Container Configuration
variable "container_image" {
  description = "Docker image for the service"
  type        = string
  default     = "ghcr.io/dspinozz/employee-management-api:latest"
}

variable "cpu" {
  description = "CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 512
}

# Service Configuration
variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 1
}

# Auto-scaling
variable "enable_autoscaling" {
  description = "Enable auto-scaling"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum tasks"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum tasks"
  type        = number
  default     = 4
}

# Application Configuration
variable "database_url" {
  description = "Database connection URL"
  type        = string
  default     = "sqlite:///data/employees.db"
}

variable "jwt_secret" {
  description = "JWT signing secret"
  type        = string
  sensitive   = true
  default     = "change-me-in-production"
}

variable "jwt_expiry" {
  description = "JWT token expiry duration"
  type        = string
  default     = "24h"
}

variable "cors_origins" {
  description = "Allowed CORS origins"
  type        = string
  default     = "*"
}
