# ------------------------------------------------------------------------------
# AWS Amplify Module Variables
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the Amplify app"
  type        = string
}

variable "repository_url" {
  description = "URL of the source repository"
  type        = string
}

variable "github_access_token" {
  description = "GitHub personal access token for repository access"
  type        = string
  sensitive   = true
  default     = ""
}

variable "branch_name" {
  description = "Branch to deploy"
  type        = string
  default     = "main"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Build Configuration
variable "build_spec" {
  description = "Custom build specification (YAML)"
  type        = string
  default     = ""
}

variable "build_output_directory" {
  description = "Build output directory"
  type        = string
  default     = "dist"
}

variable "framework" {
  description = "Framework (React, Vue, Next.js, etc.)"
  type        = string
  default     = "React"
}

variable "platform" {
  description = "Platform type (WEB or WEB_COMPUTE for SSR)"
  type        = string
  default     = "WEB"

  validation {
    condition     = contains(["WEB", "WEB_COMPUTE"], var.platform)
    error_message = "Platform must be WEB or WEB_COMPUTE."
  }
}

# Environment Variables
variable "environment_variables" {
  description = "App-level environment variables"
  type        = map(string)
  default     = {}
}

variable "branch_environment_variables" {
  description = "Branch-level environment variables"
  type        = map(string)
  default     = {}
}

# Auto Branch Configuration
variable "enable_auto_branch_creation" {
  description = "Enable automatic branch creation"
  type        = bool
  default     = false
}

variable "enable_branch_auto_build" {
  description = "Enable automatic builds for branches"
  type        = bool
  default     = true
}

variable "enable_branch_auto_deletion" {
  description = "Enable automatic branch deletion"
  type        = bool
  default     = false
}

variable "auto_branch_creation_patterns" {
  description = "Patterns for auto branch creation"
  type        = list(string)
  default     = ["feature/*", "dev"]
}

variable "enable_auto_build" {
  description = "Enable auto build for the main branch"
  type        = bool
  default     = true
}

variable "enable_pull_request_preview" {
  description = "Enable pull request previews"
  type        = bool
  default     = false
}

variable "enable_notifications" {
  description = "Enable build notifications"
  type        = bool
  default     = false
}

# Custom Rules
variable "custom_rules" {
  description = "Custom redirect/rewrite rules"
  type = list(object({
    source    = string
    target    = string
    status    = string
    condition = optional(string)
  }))
  default = [
    {
      source = "/<*>"
      target = "/index.html"
      status = "404-200"
    }
  ]
}

# Domain Configuration
variable "domain_name" {
  description = "Custom domain name"
  type        = string
  default     = ""
}

variable "subdomain_prefix" {
  description = "Subdomain prefix"
  type        = string
  default     = ""
}

variable "additional_subdomains" {
  description = "Additional subdomain configurations"
  type = list(object({
    branch_name = string
    prefix      = string
  }))
  default = []
}

variable "wait_for_verification" {
  description = "Wait for domain verification"
  type        = bool
  default     = false
}

# Webhook
variable "create_webhook" {
  description = "Create a webhook for CI/CD"
  type        = bool
  default     = false
}

# Tags
variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {}
}
