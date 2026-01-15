# ------------------------------------------------------------------------------
# Project Management System Variables
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
  default     = "ghcr.io/dspinozz/project-management-system:latest"
}

variable "cpu" {
  description = "CPU units"
  type        = number
  default     = 512  # ASP.NET Core benefits from slightly more CPU
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 1024  # .NET apps typically need more memory
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
variable "database_connection_string" {
  description = "Database connection string"
  type        = string
  default     = "Data Source=/data/projects.db"
}

variable "jwt_secret" {
  description = "JWT signing secret"
  type        = string
  sensitive   = true
  default     = "change-me-in-production-must-be-at-least-32-chars"
}

variable "jwt_issuer" {
  description = "JWT issuer"
  type        = string
  default     = "ProjectManagementSystem"
}

variable "jwt_audience" {
  description = "JWT audience"
  type        = string
  default     = "ProjectManagementSystemAPI"
}

variable "jwt_expiry_minutes" {
  description = "JWT token expiry in minutes"
  type        = number
  default     = 1440  # 24 hours
}
