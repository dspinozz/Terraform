# ------------------------------------------------------------------------------
# Azure Container Apps Variables
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the container app"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

# Container Configuration
variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "container_name" {
  description = "Name of the container (defaults to app name)"
  type        = string
  default     = ""
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU cores (0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2)"
  type        = number
  default     = 0.25

  validation {
    condition     = contains([0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2], var.cpu)
    error_message = "CPU must be one of: 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2."
  }
}

variable "memory" {
  description = "Memory in Gi (e.g., '0.5Gi', '1Gi', '2Gi')"
  type        = string
  default     = "0.5Gi"
}

# Environment Variables
variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Environment variables from secrets (name = secret_name)"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets to create (name = value). Values protected via .gitignore on tfvars files."
  type        = map(string)
  default     = {}
}

# Scaling Configuration
variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
  default     = 3
}

variable "enable_http_scaling" {
  description = "Enable HTTP-based auto-scaling"
  type        = bool
  default     = true
}

variable "http_scale_concurrent_requests" {
  description = "Concurrent requests threshold for scaling"
  type        = number
  default     = 100
}

# Revision Configuration
variable "revision_mode" {
  description = "Revision mode (Single or Multiple)"
  type        = string
  default     = "Single"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "Revision mode must be Single or Multiple."
  }
}

# Ingress Configuration
variable "external_ingress" {
  description = "Enable external ingress"
  type        = bool
  default     = true
}

# Health Probes
variable "enable_health_probes" {
  description = "Enable liveness and readiness probes"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "health_probe_initial_delay" {
  description = "Initial delay for liveness probe (seconds)"
  type        = number
  default     = 10
}

variable "health_probe_interval" {
  description = "Probe interval (seconds)"
  type        = number
  default     = 10
}

variable "health_probe_timeout" {
  description = "Probe timeout (seconds)"
  type        = number
  default     = 5
}

# Container Registry
variable "container_registry_server" {
  description = "Container registry server"
  type        = string
  default     = ""
}

variable "container_registry_username" {
  description = "Container registry username"
  type        = string
  default     = ""
}

variable "container_registry_password_secret_name" {
  description = "Name of the secret containing registry password"
  type        = string
  default     = ""
}

# Logging
variable "log_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

# Tags
variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}
