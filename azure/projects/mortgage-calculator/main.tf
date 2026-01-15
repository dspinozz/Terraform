# ------------------------------------------------------------------------------
# Mortgage Calculator (Azure Container Apps)
# Web-based calculator for mortgage vs investment comparison
# Repository: https://github.com/dspinozz/mortgage-calculator
# 
# This project demonstrates Azure expertise alongside the primary AWS stack.
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote state configuration
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "portfoliotfstate"
  #   container_name       = "tfstate"
  #   key                  = "azure/mortgage-calculator/terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

# ------------------------------------------------------------------------------
# Resource Group
# ------------------------------------------------------------------------------

module "resource_group" {
  source = "../../modules/resource-group"

  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Container App
# ------------------------------------------------------------------------------

module "container_app" {
  source = "../../modules/container-apps"

  name                = "mortgage-calculator"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  container_image = var.container_image
  container_port  = 8080
  cpu             = var.cpu
  memory          = var.memory

  # Environment variables for Flask
  environment_variables = {
    FLASK_ENV           = var.environment == "prod" ? "production" : "development"
    FLASK_DEBUG         = var.environment == "prod" ? "0" : "1"
    PYTHONUNBUFFERED    = "1"
    LOG_LEVEL           = var.environment == "prod" ? "INFO" : "DEBUG"
    SECRET_KEY          = var.flask_secret_key
    TAX_RATE_DEFAULT    = tostring(var.tax_rate_default)
    INVESTMENT_RATE     = tostring(var.investment_rate_default)
  }

  # Scaling configuration
  min_replicas = var.min_replicas
  max_replicas = var.max_replicas

  enable_http_scaling            = true
  http_scale_concurrent_requests = 50

  # Health probes
  enable_health_probes = true
  health_check_path    = "/health"

  # External access
  external_ingress = true

  log_retention_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Application = "mortgage-calculator"
    Language    = "python"
    Framework   = "flask"
  })
}

# ------------------------------------------------------------------------------
# Local Values
# ------------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Cloud       = "azure"
    ManagedBy   = "terraform"
  }
}
