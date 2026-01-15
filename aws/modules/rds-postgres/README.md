# AWS RDS PostgreSQL Module

Creates a PostgreSQL RDS instance with security groups, parameter groups, and optional Secrets Manager integration.

## Features

- PostgreSQL RDS instance (single-AZ or multi-AZ)
- Security group with configurable access rules
- Custom parameter group
- Storage autoscaling
- Performance Insights support
- Automatic backups
- Secrets Manager integration for credentials

## Usage

```hcl
module "database" {
  source = "../../modules/rds-postgres"

  name      = "portfolio-db"
  vpc_id    = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  database_name   = "portfolio"
  master_username = "postgres"
  master_password = var.db_password  # From tfvars or environment

  instance_class    = "db.t3.micro"
  allocated_storage = 20

  # Allow access from ECS tasks
  allowed_security_group_ids = [
    module.ecs_cluster.ecs_tasks_security_group_id
  ]

  # Dev settings
  multi_az              = false
  skip_final_snapshot   = true
  deletion_protection   = false

  create_secret = true

  tags = {
    Environment = "dev"
    Project     = "portfolio"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Instance identifier | string | - | yes |
| vpc_id | VPC ID | string | - | yes |
| subnet_ids | Subnet IDs | list(string) | - | yes |
| database_name | Database name | string | - | yes |
| master_username | Master username | string | "postgres" | no |
| master_password | Master password | string | - | yes |
| engine_version | PostgreSQL version | string | "15" | no |
| instance_class | Instance class | string | "db.t3.micro" | no |
| allocated_storage | Storage in GB | number | 20 | no |
| multi_az | Enable Multi-AZ | bool | false | no |
| create_secret | Create Secrets Manager secret | bool | true | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | RDS instance ID |
| endpoint | Connection endpoint |
| address | Instance hostname |
| port | Instance port |
| secret_arn | Secrets Manager ARN |

## Instance Class Guide

| Class | vCPU | Memory | Use Case |
|-------|------|--------|----------|
| db.t3.micro | 2 | 1 GB | Dev/testing (free tier) |
| db.t3.small | 2 | 2 GB | Small workloads |
| db.t3.medium | 2 | 4 GB | Medium workloads |
| db.r6g.large | 2 | 16 GB | Production |

## Cost Optimization

- Use `db.t3.micro` for dev (free tier eligible)
- Disable Multi-AZ for non-production
- Set appropriate backup retention
- Use storage autoscaling to avoid over-provisioning
