# AWS Architecture

## Overview

The AWS infrastructure hosts 5 applications using a shared VPC, ECS Cluster, and Application Load Balancer for cost efficiency and simplified management.

## Network Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           VPC (10.0.0.0/16)                                 │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                         Availability Zone A                          │   │
│   │   ┌───────────────────┐          ┌───────────────────┐              │   │
│   │   │   Public Subnet   │          │   Private Subnet  │              │   │
│   │   │   10.0.1.0/24     │          │   10.0.11.0/24    │              │   │
│   │   │                   │          │                   │              │   │
│   │   │   [ALB]           │──────────│   [ECS Tasks]     │              │   │
│   │   │   [NAT Gateway]   │          │                   │              │   │
│   │   └───────────────────┘          └───────────────────┘              │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                         Availability Zone B                          │   │
│   │   ┌───────────────────┐          ┌───────────────────┐              │   │
│   │   │   Public Subnet   │          │   Private Subnet  │              │   │
│   │   │   10.0.2.0/24     │          │   10.0.12.0/24    │              │   │
│   │   │                   │          │                   │              │   │
│   │   │   [ALB]           │──────────│   [ECS Tasks]     │              │   │
│   │   └───────────────────┘          └───────────────────┘              │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│   ┌───────────────────┐                                                     │
│   │  Internet Gateway │                                                     │
│   └─────────┬─────────┘                                                     │
│             │                                                               │
└─────────────┼───────────────────────────────────────────────────────────────┘
              │
          Internet
```

## ECS Cluster Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ECS Cluster                                       │
│                                                                             │
│   Capacity Providers: FARGATE, FARGATE_SPOT                                 │
│                                                                             │
│   ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│   │   Service   │ │   Service   │ │   Service   │ │   Service   │          │
│   │             │ │             │ │             │ │             │          │
│   │  audit-log  │ │  employee   │ │  project    │ │  php-rest   │          │
│   │ aggregator  │ │ management  │ │ management  │ │    api      │          │
│   │   (Rust)    │ │    (Go)     │ │   (C#)      │ │   (PHP)     │          │
│   │             │ │             │ │             │ │             │          │
│   │ Port: 8080  │ │ Port: 8080  │ │ Port: 8080  │ │ Port: 8080  │          │
│   │ CPU: 256    │ │ CPU: 256    │ │ CPU: 512    │ │ CPU: 256    │          │
│   │ Mem: 512    │ │ Mem: 512    │ │ Mem: 1024   │ │ Mem: 512    │          │
│   └──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └──────┬──────┘          │
│          │               │               │               │                  │
│          └───────────────┴───────────────┴───────────────┘                  │
│                                    │                                        │
│                          ┌─────────▼─────────┐                              │
│                          │ Target Groups     │                              │
│                          └─────────┬─────────┘                              │
│                                    │                                        │
└────────────────────────────────────┼────────────────────────────────────────┘
                                     │
                           ┌─────────▼─────────┐
                           │        ALB        │
                           │                   │
                           │  Path-based       │
                           │  Routing:         │
                           │  /audit/*    →    │
                           │  /employees/* →   │
                           │  /projects/*  →   │
                           │  /php/*       →   │
                           └───────────────────┘
```

## ALB Routing Rules

| Priority | Path Pattern | Target Service |
|----------|-------------|----------------|
| 100 | `/audit/*`, `/api/audit/*` | audit-log-aggregator |
| 200 | `/employees/*`, `/api/employees/*` | employee-management-api |
| 300 | `/projects/*`, `/api/projects/*` | project-management-system |
| 400 | `/php/*`, `/api/php/*` | php-rest-api |

## Security Groups

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Security Groups                               │
│                                                                     │
│   ┌─────────────────┐          ┌─────────────────┐                  │
│   │   ALB SG        │          │   ECS Tasks SG  │                  │
│   │                 │          │                 │                  │
│   │ Inbound:        │          │ Inbound:        │                  │
│   │   80 (HTTP)     │ ───────► │   All from ALB  │                  │
│   │   443 (HTTPS)   │          │                 │                  │
│   │                 │          │ Outbound:       │                  │
│   │ Outbound:       │          │   All (0.0.0.0) │                  │
│   │   All           │          │                 │                  │
│   └─────────────────┘          └─────────────────┘                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## AWS Amplify (Calculator App)

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AWS Amplify                                   │
│                                                                     │
│   ┌─────────────────┐          ┌─────────────────┐                  │
│   │   GitHub Repo   │ ──push──►│   Amplify App   │                  │
│   │   main branch   │          │                 │                  │
│   └─────────────────┘          │   Build:        │                  │
│                                │   npm ci        │                  │
│                                │   npm run build │                  │
│                                │                 │                  │
│                                │   Deploy:       │                  │
│                                │   web-build/    │                  │
│                                └────────┬────────┘                  │
│                                         │                           │
│                                         ▼                           │
│                           https://main.xxx.amplifyapp.com           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## IAM Roles

| Role | Purpose | Permissions |
|------|---------|-------------|
| ECS Task Execution Role | Pull images, write logs | `AmazonECSTaskExecutionRolePolicy`, Secrets Manager read |
| ECS Task Role | Application permissions | Custom per-service |
| VPC Flow Logs Role | Write flow logs | CloudWatch Logs write |

## Cost Breakdown

| Resource | Purpose | Monthly Cost (Dev) |
|----------|---------|-------------------|
| NAT Gateway | Private subnet internet | ~$32 |
| ALB | Load balancing | ~$16 |
| ECS Fargate (4 services) | Container hosting | ~$15 |
| CloudWatch Logs | Logging | ~$5 |
| Amplify | Static hosting | Free tier |
| **Total** | | **~$68** |

## High Availability

- **VPC**: Multi-AZ subnets (2 AZs by default)
- **ECS**: Tasks distributed across AZs
- **ALB**: Spans multiple AZs
- **NAT**: Single NAT (dev) or Multi-NAT (prod)
