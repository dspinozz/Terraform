# ------------------------------------------------------------------------------
# Calculator App Variables
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

# Repository Configuration
variable "repository_url" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/dspinozz/calculator-app-react-native-expo"
}

variable "github_access_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "branch_name" {
  description = "Git branch to deploy"
  type        = string
  default     = "main"
}

# Application Configuration
variable "api_url" {
  description = "Backend API URL"
  type        = string
  default     = ""
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}

# Features
variable "enable_pr_preview" {
  description = "Enable pull request previews"
  type        = bool
  default     = false
}

# Custom Domain
variable "domain_name" {
  description = "Custom domain name"
  type        = string
  default     = ""
}

variable "subdomain_prefix" {
  description = "Subdomain prefix (e.g., 'app' for app.example.com)"
  type        = string
  default     = ""
}
