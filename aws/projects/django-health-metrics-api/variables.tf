# ------------------------------------------------------------------------------
# Django Health Metrics API Variables
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
  default     = "ghcr.io/dspinozz/django-health:latest"
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

# Django Application Configuration
variable "django_secret_key" {
  description = "Django secret key"
  type        = string
  sensitive   = true
  default     = "change-me-in-production-use-secure-random-key"
}

variable "allowed_hosts" {
  description = "Comma-separated list of allowed hosts"
  type        = string
  default     = "*"
}

variable "cors_origins" {
  description = "Allowed CORS origins"
  type        = string
  default     = "*"
}

# Database Configuration
variable "use_rds" {
  description = "Use RDS PostgreSQL instead of SQLite"
  type        = bool
  default     = false
}

variable "database_url" {
  description = "Database connection URL (if not using RDS)"
  type        = string
  default     = "sqlite:///db.sqlite3"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "healthmetrics"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
  default     = "change-me-in-production"
}
