# ------------------------------------------------------------------------------
# Audit Log Aggregator Variables
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
  default     = "ghcr.io/dspinozz/audit-log-aggregator:latest"
}

variable "cpu" {
  description = "CPU units (256, 512, 1024, 2048, 4096)"
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
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 4
}

# Application Configuration
variable "database_url" {
  description = "Database connection URL"
  type        = string
  default     = "sqlite:///data/audit.db"
}

variable "cors_origins" {
  description = "Allowed CORS origins"
  type        = string
  default     = "*"
}

variable "jwt_secret" {
  description = "JWT signing secret"
  type        = string
  sensitive   = true
  default     = "change-me-in-production"
}

variable "rate_limit_rps" {
  description = "Rate limit requests per second"
  type        = number
  default     = 100
}
