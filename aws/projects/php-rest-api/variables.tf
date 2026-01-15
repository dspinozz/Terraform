# ------------------------------------------------------------------------------
# PHP REST API Variables
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
  default     = "ghcr.io/dspinozz/php-rest-api:latest"
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

# Database Configuration
variable "database_driver" {
  description = "Database driver (sqlite, mysql, pgsql)"
  type        = string
  default     = "sqlite"
}

variable "database_host" {
  description = "Database host"
  type        = string
  default     = "localhost"
}

variable "database_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "phpapi"
}

variable "database_user" {
  description = "Database user"
  type        = string
  default     = "phpapi"
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = ""
}

# JWT Configuration
variable "jwt_secret" {
  description = "JWT signing secret"
  type        = string
  sensitive   = true
  default     = "change-me-in-production"
}

variable "jwt_algorithm" {
  description = "JWT algorithm"
  type        = string
  default     = "HS256"
}

variable "jwt_expiry" {
  description = "JWT expiry in seconds"
  type        = number
  default     = 3600
}

# API Configuration
variable "cors_origins" {
  description = "Allowed CORS origins"
  type        = string
  default     = "*"
}

variable "rate_limit_max" {
  description = "Rate limit max requests"
  type        = number
  default     = 100
}

variable "rate_limit_window" {
  description = "Rate limit window in seconds"
  type        = number
  default     = 60
}
