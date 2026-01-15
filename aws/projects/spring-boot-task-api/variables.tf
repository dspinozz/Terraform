# ------------------------------------------------------------------------------
# Spring Boot Task API Variables
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
  default     = "ghcr.io/dspinozz/spring-boot-task-api:latest"
}

variable "cpu" {
  description = "CPU units (256 = 0.25 vCPU)"
  type        = number
  default     = 512
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 1024
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

# Spring Boot Configuration
variable "spring_profile" {
  description = "Spring active profile"
  type        = string
  default     = "default"
}

variable "java_opts" {
  description = "JVM options"
  type        = string
  default     = "-Xmx768m -Xms256m"
}

# Database Configuration
variable "database_url" {
  description = "JDBC database connection URL"
  type        = string
  default     = "jdbc:h2:mem:taskdb"
}

variable "database_username" {
  description = "Database username"
  type        = string
  default     = "sa"
}

variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = ""
}
