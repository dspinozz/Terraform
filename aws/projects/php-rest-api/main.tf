# ------------------------------------------------------------------------------
# PHP REST API Service
# Framework-agnostic REST API framework for PHP 8.2+
# Repository: https://github.com/dspinozz/PHP-Rest-API
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
  #   key            = "aws/php-rest-api/terraform.tfstate"
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
      Application = "php-rest-api"
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

  name         = "php-rest-api"
  cluster_name = data.terraform_remote_state.shared.outputs.ecs_cluster_name
  cluster_arn  = data.terraform_remote_state.shared.outputs.ecs_cluster_arn
  vpc_id       = data.terraform_remote_state.shared.outputs.vpc_id
  subnet_ids   = data.terraform_remote_state.shared.outputs.private_subnet_ids
  aws_region   = var.aws_region

  security_group_ids = [data.terraform_remote_state.shared.outputs.ecs_tasks_security_group_id]
  execution_role_arn = data.terraform_remote_state.shared.outputs.task_execution_role_arn

  # Container configuration
  container_image = var.container_image
  container_port  = 8080
  cpu             = var.cpu
  memory          = var.memory

  # Environment variables
  environment_variables = {
    APP_ENV           = var.environment
    APP_DEBUG         = var.environment == "prod" ? "false" : "true"
    DATABASE_DRIVER   = var.database_driver
    DATABASE_HOST     = var.database_host
    DATABASE_PORT     = tostring(var.database_port)
    DATABASE_NAME     = var.database_name
    DATABASE_USER     = var.database_user
    DATABASE_PASSWORD = var.database_password
    JWT_SECRET        = var.jwt_secret
    JWT_ALGORITHM     = var.jwt_algorithm
    JWT_EXPIRY        = tostring(var.jwt_expiry)
    CORS_ORIGINS      = var.cors_origins
    RATE_LIMIT_MAX    = tostring(var.rate_limit_max)
    RATE_LIMIT_WINDOW = tostring(var.rate_limit_window)
  }

  # ALB routing
  create_alb_target_group = true
  listener_arn            = data.terraform_remote_state.shared.outputs.http_listener_arn
  listener_rule_priority  = 400
  path_patterns           = ["/php/*", "/api/php/*"]
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
    Application = "php-rest-api"
    Language    = "php"
    Version     = "8.2"
  }
}
