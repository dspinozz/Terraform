# ------------------------------------------------------------------------------
# Mortgage Calculator Variables
# ------------------------------------------------------------------------------

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "portfolio"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# Container Configuration
variable "container_image" {
  description = "Docker image for the service"
  type        = string
  default     = "ghcr.io/dspinozz/mortgage-calculator:latest"
}

variable "cpu" {
  description = "CPU cores"
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory (e.g., '0.5Gi')"
  type        = string
  default     = "0.5Gi"
}

# Scaling Configuration
variable "min_replicas" {
  description = "Minimum replicas (0 for scale-to-zero)"
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum replicas"
  type        = number
  default     = 3
}

# Application Configuration
variable "flask_secret_key" {
  description = "Flask secret key for sessions"
  type        = string
  sensitive   = true
  default     = "change-me-in-production"
}

variable "tax_rate_default" {
  description = "Default tax rate for calculations"
  type        = number
  default     = 0.25
}

variable "investment_rate_default" {
  description = "Default investment return rate"
  type        = number
  default     = 0.07
}

# Logging
variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}
