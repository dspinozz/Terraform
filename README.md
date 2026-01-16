# Cloud Infrastructure Portfolio

Production-ready Terraform infrastructure for a multi-application portfolio deployed across AWS (primary) and Azure (secondary).

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS (Primary)                                   │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                           VPC (10.0.0.0/16)                            │ │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────┐  │ │
│  │  │  Public Subnet   │  │  Public Subnet   │  │   Public Subnet      │  │ │
│  │  │   10.0.1.0/24    │  │   10.0.2.0/24    │  │    10.0.3.0/24       │  │ │
│  │  │      (AZ-a)      │  │      (AZ-b)      │  │       (AZ-c)         │  │ │
│  │  └────────┬─────────┘  └────────┬─────────┘  └──────────┬───────────┘  │ │
│  │           │ ALB                 │                       │              │ │
│  │  ┌────────▼─────────────────────▼───────────────────────▼───────────┐  │ │
│  │  │                    Application Load Balancer                     │  │ │
│  │  └────────┬─────────────────────┬───────────────────────┬───────────┘  │ │
│  │           │                     │                       │              │ │
│  │  ┌────────▼─────────┐  ┌────────▼─────────┐  ┌──────────▼───────────┐  │ │
│  │  │  Private Subnet  │  │  Private Subnet  │  │   Private Subnet     │  │ │
│  │  │   10.0.11.0/24   │  │   10.0.12.0/24   │  │    10.0.13.0/24      │  │ │
│  │  │      (AZ-a)      │  │      (AZ-b)      │  │       (AZ-c)         │  │ │
│  │  └────────┬─────────┘  └────────┬─────────┘  └──────────┬───────────┘  │ │
│  │           │                     │                       │              │ │
│  │  ┌────────▼─────────────────────▼───────────────────────▼───────────┐  │ │
│  │  │                        ECS Cluster                               │  │ │
│  │  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │  │ │
│  │  │  │audit-log-   │ │employee-    │ │project-     │ │php-rest-api │ │  │ │
│  │  │  │aggregator   │ │management   │ │management   │ │             │ │  │ │
│  │  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ │  │ │
│  │  │  ┌─────────────┐ ┌─────────────┐                                 │  │ │
│  │  │  │spring-boot- │ │django-      │                                 │  │ │
│  │  │  │task-api     │ │health-api   │                                 │  │ │
│  │  │  └─────────────┘ └─────────────┘                                 │  │ │
│  │  └──────────────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ┌────────────────────┐                                                     │
│  │   AWS Amplify      │  calculator-app (React Native Web)                  │
│  └────────────────────┘                                                     │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                            Azure (Secondary)                                 │
│  ┌────────────────────────────────────────────────────────────────────────┐ │
│  │                      Resource Group: portfolio-rg                       │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │  │              Container Apps Environment                           │  │ │
│  │  │  ┌────────────────────────────────────────────────────────────┐  │  │ │
│  │  │  │              mortgage-calculator                            │  │  │ │
│  │  │  │              (Python Flask)                                 │  │  │ │
│  │  │  └────────────────────────────────────────────────────────────┘  │  │ │
│  │  └──────────────────────────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Repository Structure

```
terraform-cloud-infrastructure/
├── aws/
│   ├── modules/
│   │   ├── vpc/                    # Network foundation
│   │   ├── ecs-cluster/            # Shared ECS cluster
│   │   ├── ecs-service/            # Reusable service module
│   │   ├── rds-postgres/           # Database module
│   │   └── amplify/                # Static/SSR hosting
│   └── projects/
│       ├── shared-infrastructure/  # VPC, ECS cluster, shared resources
│       ├── audit-log-aggregator/
│       ├── django-health-metrics-api/  # NEW
│       ├── employee-management-api/
│       ├── project-management-system/
│       ├── php-rest-api/
│       ├── spring-boot-task-api/
│       └── calculator-app/
├── azure/
│   ├── modules/
│   │   ├── resource-group/
│   │   └── container-apps/
│   └── projects/
│       └── mortgage-calculator/
├── docs/
│   ├── aws-architecture.md
│   ├── azure-architecture.md
│   └── deployment-guide.md
└── README.md
```

## Deployed Applications

| Application | Cloud | Service | Language | Description |
|-------------|-------|---------|----------|-------------|
| audit-log-aggregator | AWS | ECS Fargate | Rust | High-performance audit log system |
| django-health-metrics-api | AWS | ECS Fargate | Python | Health metrics tracking with Django REST Framework |
| employee-management-api | AWS | ECS Fargate | Go | REST API with JWT auth |
| project-management-system | AWS | ECS Fargate | C# | ASP.NET Core API |
| php-rest-api | AWS | ECS Fargate | PHP | Framework-agnostic REST API |
| spring-boot-task-api | AWS | ECS Fargate | Java | Personal task management with Spring Boot |
| calculator-app | AWS | Amplify | TypeScript | React Native cross-platform app |
| mortgage-calculator | Azure | Container Apps | Python | Financial comparison tool |

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.6.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with credentials
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) configured with credentials
- Docker (for building container images)

## Quick Start

### 1. Clone and Initialize

```bash
git clone https://github.com/dspinozz/terraform-cloud-infrastructure.git
cd terraform-cloud-infrastructure
```

### 2. Deploy AWS Shared Infrastructure

```bash
cd aws/projects/shared-infrastructure
terraform init
terraform plan
terraform apply
```

### 3. Deploy Individual Services

```bash
# Example: Deploy Django Health Metrics API
cd aws/projects/django-health-metrics-api
terraform init
terraform plan
terraform apply
```

### 4. Deploy Azure Resources

```bash
cd azure/projects/mortgage-calculator
terraform init
terraform plan
terraform apply
```

## Cost Estimation

| Resource | Monthly Cost (Dev) | Monthly Cost (Prod) |
|----------|-------------------|---------------------|
| AWS VPC + NAT Gateway | ~$32 | ~$32 |
| ECS Fargate (6 services) | ~$24 | ~$90 |
| ALB | ~$16 | ~$16 |
| AWS Amplify | Free tier | ~$5 |
| Azure Container Apps | ~$0 (free tier) | ~$10 |
| **Total** | **~$72/month** | **~$153/month** |

*Note: Costs can be reduced by destroying resources when not in use.*

## Module Documentation

- [VPC Module](./aws/modules/vpc/README.md)
- [ECS Cluster Module](./aws/modules/ecs-cluster/README.md)
- [ECS Service Module](./aws/modules/ecs-service/README.md)
- [RDS PostgreSQL Module](./aws/modules/rds-postgres/README.md)
- [Azure Container Apps Module](./azure/modules/container-apps/README.md)

## State Management

Remote state is stored in:
- **AWS**: S3 bucket with DynamoDB locking
- **Azure**: Azure Storage Account with blob locking

See [Deployment Guide](./docs/deployment-guide.md) for backend configuration.

## Security Features

- Private subnets for all application workloads
- Security groups with least-privilege access
- Secrets managed via AWS Secrets Manager / Azure Key Vault
- HTTPS-only traffic via ALB/Container Apps ingress
- IAM roles with minimal required permissions

## License

MIT License - See [LICENSE](./LICENSE) for details.
