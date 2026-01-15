# AWS ECS Service Module

Creates an ECS Fargate service with task definition, auto-scaling, and ALB integration. This module is designed to be reused across multiple applications.

## Features

- ECS Fargate service with configurable resources
- Task definition with environment variables and secrets
- ALB target group and listener rule integration
- Configurable health checks
- Auto-scaling based on CPU/memory utilization
- Deployment circuit breaker with rollback
- CloudWatch logging
- ECS Exec support for debugging

## Usage

### Basic Usage

```hcl
module "api_service" {
  source = "../../modules/ecs-service"

  name         = "my-api"
  cluster_name = module.ecs_cluster.cluster_name
  cluster_arn  = module.ecs_cluster.cluster_arn
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids
  aws_region   = "us-east-1"

  security_group_ids = [module.ecs_cluster.ecs_tasks_security_group_id]
  execution_role_arn = module.ecs_cluster.task_execution_role_arn

  container_image = "ghcr.io/dspinozz/my-api:latest"
  container_port  = 8080
  cpu             = 256
  memory          = 512

  environment_variables = {
    APP_ENV      = "production"
    DATABASE_URL = "postgres://..."
  }

  # ALB routing
  create_alb_target_group = true
  listener_arn            = module.ecs_cluster.http_listener_arn
  listener_rule_priority  = 100
  path_patterns           = ["/api/*"]
  health_check_path       = "/health"

  tags = {
    Environment = "dev"
    Application = "my-api"
  }
}
```

### With Auto-Scaling

```hcl
module "api_service" {
  source = "../../modules/ecs-service"

  # ... other configuration ...

  enable_autoscaling       = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 4
  autoscaling_cpu_target   = 70
}
```

### With Secrets

```hcl
module "api_service" {
  source = "../../modules/ecs-service"

  # ... other configuration ...

  secrets = {
    DATABASE_PASSWORD = "arn:aws:secretsmanager:us-east-1:123456789:secret:db-password"
    JWT_SECRET        = "arn:aws:secretsmanager:us-east-1:123456789:secret:jwt-secret"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the ECS service | string | - | yes |
| cluster_name | Name of the ECS cluster | string | - | yes |
| cluster_arn | ARN of the ECS cluster | string | - | yes |
| vpc_id | VPC ID | string | - | yes |
| subnet_ids | Subnet IDs for the service | list(string) | - | yes |
| security_group_ids | Security group IDs | list(string) | - | yes |
| container_image | Docker image | string | - | yes |
| execution_role_arn | Task execution role ARN | string | - | yes |
| container_port | Container port | number | 8080 | no |
| cpu | CPU units | number | 256 | no |
| memory | Memory in MB | number | 512 | no |
| desired_count | Number of tasks | number | 1 | no |
| environment_variables | Environment variables | map(string) | {} | no |
| secrets | Secrets Manager ARNs | map(string) | {} | no |
| health_check_path | Health check path | string | "/health" | no |
| enable_autoscaling | Enable auto-scaling | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| service_id | ID of the ECS service |
| service_name | Name of the ECS service |
| task_definition_arn | ARN of the task definition |
| target_group_arn | ARN of the ALB target group |
| log_group_name | CloudWatch log group name |

## Resource Sizing Guide

| Workload | CPU | Memory | Notes |
|----------|-----|--------|-------|
| Light API | 256 | 512 | Small APIs, microservices |
| Medium API | 512 | 1024 | Standard REST APIs |
| Heavy API | 1024 | 2048 | Complex processing |
| Background worker | 256-512 | 512-1024 | Async processing |

## Cost Optimization Tips

1. Use FARGATE_SPOT for non-critical workloads (up to 70% savings)
2. Right-size CPU/memory based on actual usage
3. Enable auto-scaling with appropriate min/max
4. Use ARM64 architecture when possible (20% cheaper)
