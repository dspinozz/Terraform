# ------------------------------------------------------------------------------
# Audit Log Aggregator Service
# High-performance audit log aggregation system built with Rust
# Repository: https://github.com/dspinozz/audit-log-aggregator
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state configuration
  # backend "s3" {
  #   bucket         = "portfolio-terraform-state"
  #   key            = "aws/audit-log-aggregator/terraform.tfstate"
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
      Application = "audit-log-aggregator"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

# ------------------------------------------------------------------------------
# Remote State Data Sources
# ------------------------------------------------------------------------------

data "terraform_remote_state" "shared" {
  backend = "local"  # Change to "s3" for production

  config = {
    path = "../shared-infrastructure/terraform.tfstate"
  }
}

# ------------------------------------------------------------------------------
# ECS Service
# ------------------------------------------------------------------------------

module "service" {
  source = "../../modules/ecs-service"

  name         = "audit-log-aggregator"
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
    RUST_LOG          = var.environment == "prod" ? "info" : "debug"
    DATABASE_URL      = var.database_url
    CORS_ORIGINS      = var.cors_origins
    JWT_SECRET        = var.jwt_secret
    RATE_LIMIT_RPS    = tostring(var.rate_limit_rps)
  }

  # ALB routing - path-based routing
  create_alb_target_group = true
  listener_arn            = data.terraform_remote_state.shared.outputs.http_listener_arn
  listener_rule_priority  = 100
  path_patterns           = ["/audit/*", "/api/audit/*"]
  health_check_path       = "/health"
  health_check_matcher    = "200"

  # Service configuration
  desired_count = var.desired_count

  # Auto-scaling
  enable_autoscaling       = var.enable_autoscaling
  autoscaling_min_capacity = var.autoscaling_min_capacity
  autoscaling_max_capacity = var.autoscaling_max_capacity
  autoscaling_cpu_target   = 70

  # Deployment
  enable_circuit_breaker          = true
  enable_circuit_breaker_rollback = true

  tags = {
    Application = "audit-log-aggregator"
    Language    = "rust"
  }
}
