# ------------------------------------------------------------------------------
# Calculator App (AWS Amplify)
# Full-stack calculator with React Native/Expo, multi-tenancy, and RBAC
# Repository: https://github.com/dspinozz/calculator-app-react-native-expo
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # backend "s3" {
  #   bucket         = "portfolio-terraform-state"
  #   key            = "aws/calculator-app/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "portfolio"
      Application = "calculator-app"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

# ------------------------------------------------------------------------------
# Amplify App
# ------------------------------------------------------------------------------

module "amplify" {
  source = "../../modules/amplify"

  name           = "calculator-app"
  repository_url = var.repository_url
  branch_name    = var.branch_name
  environment    = var.environment

  github_access_token = var.github_access_token

  # Build configuration for Expo web
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build:web
      artifacts:
        baseDirectory: web-build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  build_output_directory = "web-build"
  framework              = "React"
  platform               = "WEB"

  # Environment variables
  environment_variables = {
    REACT_APP_API_URL     = var.api_url
    REACT_APP_ENVIRONMENT = var.environment
  }

  branch_environment_variables = {
    REACT_APP_VERSION = var.app_version
  }

  # SPA routing
  custom_rules = [
    {
      source = "/<*>"
      target = "/index.html"
      status = "404-200"
    }
  ]

  # Auto-build on push
  enable_auto_build           = true
  enable_pull_request_preview = var.enable_pr_preview

  # Custom domain (optional)
  domain_name      = var.domain_name
  subdomain_prefix = var.subdomain_prefix

  tags = {
    Application = "calculator-app"
    Framework   = "react-native-expo"
  }
}
