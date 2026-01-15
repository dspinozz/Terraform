# AWS ECS Cluster Module

Creates a shared ECS Fargate cluster with Application Load Balancer and proper IAM configuration.

## Features

- ECS Fargate cluster with Container Insights
- Configurable capacity providers (FARGATE and FARGATE_SPOT)
- Shared Application Load Balancer
- Task execution IAM role with Secrets Manager access
- Base security group for ECS tasks
- CloudWatch log group for cluster logging

## Usage

```hcl
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  name              = "portfolio"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  enable_container_insights = true
  create_alb                = true

  # Use FARGATE_SPOT for cost savings in dev
  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "portfolio"
  }
}
```

## Architecture

```
                    Internet
                       │
                       ▼
              ┌────────────────┐
              │      ALB       │
              │  (port 80/443) │
              └────────┬───────┘
                       │
           ┌───────────┼───────────┐
           │           │           │
           ▼           ▼           ▼
      ┌─────────┐ ┌─────────┐ ┌─────────┐
      │ Service │ │ Service │ │ Service │
      │    A    │ │    B    │ │    C    │
      └─────────┘ └─────────┘ └─────────┘
              ECS Cluster (Fargate)
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the ECS cluster | string | - | yes |
| vpc_id | VPC ID | string | - | yes |
| public_subnet_ids | Public subnet IDs for ALB | list(string) | [] | no |
| enable_container_insights | Enable Container Insights | bool | true | no |
| capacity_providers | Capacity providers to use | list(string) | ["FARGATE", "FARGATE_SPOT"] | no |
| create_alb | Create shared ALB | bool | true | no |
| certificate_arn | ACM certificate ARN | string | "" | no |
| tags | Tags for resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_arn | ARN of the ECS cluster |
| task_execution_role_arn | ARN of task execution role |
| ecs_tasks_security_group_id | Security group for tasks |
| alb_arn | ARN of the ALB |
| alb_dns_name | DNS name of the ALB |
| http_listener_arn | ARN of HTTP listener |

## Cost Optimization

- **FARGATE_SPOT**: Up to 70% cheaper than regular Fargate
- Use FARGATE_SPOT for dev/staging workloads
- Use regular FARGATE with base=1 for production (ensures minimum capacity)
