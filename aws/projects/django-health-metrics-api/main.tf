# ------------------------------------------------------------------------------
# Django Health Metrics API Service
# REST API for tracking personal health metrics, goals, and progress
# Repository: https://github.com/dspinozz/Django-Health
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
  #   key            = "aws/django-health-metrics-api/terraform.tfstate"
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
      Application = "django-health-metrics-api"
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
# RDS PostgreSQL Database (Optional - uses module if enabled)
# ------------------------------------------------------------------------------

module "database" {
  source = "../../modules/rds-postgres"
  count  = var.use_rds ? 1 : 0

  name               = "django-health-db"
  vpc_id             = data.terraform_remote_state.shared.outputs.vpc_id
  subnet_ids         = data.terraform_remote_state.shared.outputs.private_subnet_ids
  security_group_ids = [data.terraform_remote_state.shared.outputs.rds_security_group_id]

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  database_name     = "healthmetrics"
  username          = var.db_username
  password          = var.db_password

  tags = {
    Application = "django-health-metrics-api"
  }
}

# ------------------------------------------------------------------------------
# ECS Service
# ------------------------------------------------------------------------------

module "service" {
  source = "../../modules/ecs-service"

  name         = "django-health-metrics-api"
  cluster_name = data.terraform_remote_state.shared.outputs.ecs_cluster_name
  cluster_arn  = data.terraform_remote_state.shared.outputs.ecs_cluster_arn
  vpc_id       = data.terraform_remote_state.shared.outputs.vpc_id
  subnet_ids   = data.terraform_remote_state.shared.outputs.private_subnet_ids
  aws_region   = var.aws_region

  security_group_ids = [data.terraform_remote_state.shared.outputs.ecs_tasks_security_group_id]
  execution_role_arn = data.terraform_remote_state.shared.outputs.task_execution_role_arn

  # Container configuration
  container_image = var.container_image
  container_port  = 8000
  cpu             = var.cpu
  memory          = var.memory

  # Environment variables
  environment_variables = {
    DJANGO_SETTINGS_MODULE = "config.settings"
    DEBUG                  = var.environment == "prod" ? "False" : "True"
    ALLOWED_HOSTS          = var.allowed_hosts
    DJANGO_SECRET_KEY      = var.django_secret_key
    DATABASE_URL           = var.use_rds ? module.database[0].connection_url : var.database_url
    CORS_ORIGINS           = var.cors_origins
  }

  # ALB routing
  create_alb_target_group = true
  listener_arn            = data.terraform_remote_state.shared.outputs.http_listener_arn
  listener_rule_priority  = 300
  path_patterns           = ["/api/v1/*", "/admin/*", "/health/*"]
  health_check_path       = "/"
  health_check_matcher    = "200"

  # Service configuration
  desired_count = var.desired_count

  # Auto-scaling
  enable_autoscaling       = var.enable_autoscaling
  autoscaling_min_capacity = var.autoscaling_min_capacity
  autoscaling_max_capacity = var.autoscaling_max_capacity
  autoscaling_cpu_target   = 70

  tags = {
    Application = "django-health-metrics-api"
    Language    = "python"
    Framework   = "django"
  }
}
