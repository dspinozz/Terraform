# ------------------------------------------------------------------------------
# Spring Boot Task API Service
# Personal Task Management API with Categories & Priorities - Java/Spring Boot
# Repository: https://github.com/dspinozz/Java-Spring-Boot
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
  #   key            = "aws/spring-boot-task-api/terraform.tfstate"
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
      Application = "spring-boot-task-api"
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

  name         = "spring-boot-task-api"
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
    SPRING_PROFILES_ACTIVE = var.spring_profile
    SERVER_PORT            = "8080"
    SPRING_DATASOURCE_URL  = var.database_url
    SPRING_DATASOURCE_USER = var.database_username
    SPRING_DATASOURCE_PASS = var.database_password
    JAVA_OPTS              = var.java_opts
  }

  # ALB routing
  create_alb_target_group = true
  listener_arn            = data.terraform_remote_state.shared.outputs.http_listener_arn
  listener_rule_priority  = 300
  path_patterns           = ["/api/tasks/*", "/api/categories/*", "/api/health"]
  health_check_path       = "/api/health"
  health_check_matcher    = "200"

  # Service configuration
  desired_count = var.desired_count

  # Auto-scaling
  enable_autoscaling       = var.enable_autoscaling
  autoscaling_min_capacity = var.autoscaling_min_capacity
  autoscaling_max_capacity = var.autoscaling_max_capacity
  autoscaling_cpu_target   = 70

  tags = {
    Application = "spring-boot-task-api"
    Language    = "java"
    Framework   = "spring-boot"
  }
}
