# ------------------------------------------------------------------------------
# Shared Infrastructure
# Creates the foundational AWS resources used by all applications:
# - VPC with public and private subnets
# - ECS Cluster with ALB
# - Shared security groups
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
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket         = "portfolio-terraform-state"
  #   key            = "aws/shared-infrastructure/terraform.tfstate"
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
      ManagedBy   = "terraform"
      Repository  = "terraform-cloud-infrastructure"
      Environment = var.environment
    }
  }
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  name     = "${var.project_name}-${var.environment}"
  vpc_cidr = var.vpc_cidr
  az_count = var.az_count

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_flow_logs         = var.enable_flow_logs
  flow_logs_retention_days = 14

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# ECS Cluster
# ------------------------------------------------------------------------------

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  name              = "${var.project_name}-${var.environment}"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  enable_container_insights = var.enable_container_insights
  create_alb                = true
  log_retention_days        = var.log_retention_days

  # Use FARGATE_SPOT for dev to reduce costs
  default_capacity_provider_strategy = var.environment == "prod" ? [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 4
    }
  ] : [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
    }
  ]

  # HTTPS configuration (optional)
  redirect_http_to_https = var.certificate_arn != ""
  certificate_arn        = var.certificate_arn

  enable_secrets_manager_access = true
  secrets_arns                  = ["arn:aws:secretsmanager:${var.aws_region}:*:secret:${var.project_name}/*"]

  tags = local.common_tags
}

# ------------------------------------------------------------------------------
# Local Values
# ------------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
