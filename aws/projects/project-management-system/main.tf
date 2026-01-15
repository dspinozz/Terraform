# ------------------------------------------------------------------------------
# Project Management System Service
# ASP.NET Core 8.0 API with JWT Authentication and RBAC
# Repository: https://github.com/dspinozz/ProjectManagementSystem
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
  #   key            = "aws/project-management-system/terraform.tfstate"
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
      Application = "project-management-system"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

# ------------------------------------------------------------------------------
# Remote State Data Sources
# ------------------------------------------------------------------------------

data "terraform_remote_state" "shared" {
  backend = "local"

  config = {
    path = "../shared-infrastructure/terraform.tfstate"
  }
}

# ------------------------------------------------------------------------------
# ECS Service
# ------------------------------------------------------------------------------

module "service" {
  source = "../../modules/ecs-service"

  name         = "project-management-system"
  cluster_name = data.terraform_remote_state.shared.outputs.ecs_cluster_name
  cluster_arn  = data.terraform_remote_state.shared.outputs.ecs_cluster_arn
  vpc_id       = data.terraform_remote_state.shared.outputs.vpc_id
  subnet_ids   = data.terraform_remote_state.shared.outputs.private_subnet_ids
  aws_region   = var.aws_region

  security_group_ids = [data.terraform_remote_state.shared.outputs.ecs_tasks_security_group_id]
  execution_role_arn = data.terraform_remote_state.shared.outputs.task_execution_role_arn

  # Container configuration - ASP.NET Core uses 8080 by default in containers
  container_image = var.container_image
  container_port  = 8080
  cpu             = var.cpu
  memory          = var.memory

  # Environment variables for ASP.NET Core
  environment_variables = {
    ASPNETCORE_ENVIRONMENT    = var.environment == "prod" ? "Production" : "Development"
    ASPNETCORE_URLS           = "http://+:8080"
    ConnectionStrings__Default = var.database_connection_string
    Jwt__Secret               = var.jwt_secret
    Jwt__Issuer               = var.jwt_issuer
    Jwt__Audience             = var.jwt_audience
    Jwt__ExpiryMinutes        = tostring(var.jwt_expiry_minutes)
    Logging__LogLevel__Default = var.environment == "prod" ? "Information" : "Debug"
  }

  # ALB routing
  create_alb_target_group = true
  listener_arn            = data.terraform_remote_state.shared.outputs.http_listener_arn
  listener_rule_priority  = 300
  path_patterns           = ["/projects/*", "/api/projects/*"]
  health_check_path       = "/health"
  health_check_matcher    = "200"

  # Service configuration
  desired_count = var.desired_count

  # Auto-scaling
  enable_autoscaling       = var.enable_autoscaling
  autoscaling_min_capacity = var.autoscaling_min_capacity
  autoscaling_max_capacity = var.autoscaling_max_capacity
  autoscaling_cpu_target   = 70

  tags = {
    Application = "project-management-system"
    Language    = "csharp"
    Framework   = "aspnet-core-8"
  }
}
