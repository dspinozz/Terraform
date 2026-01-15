# Deployment Guide

This guide covers deploying the portfolio infrastructure to AWS and Azure.

## Prerequisites

### Required Tools

```bash
# Install Terraform
brew install terraform  # macOS
# or download from https://www.terraform.io/downloads

# Install AWS CLI
brew install awscli
aws configure

# Install Azure CLI
brew install azure-cli
az login
```

### Required Accounts

- AWS Account with IAM credentials
- Azure Account with subscription
- GitHub account (for Amplify and Container Apps)

## Deployment Order

Deploy in this order to satisfy dependencies:

```
1. AWS Shared Infrastructure (VPC, ECS Cluster, ALB)
   ↓
2. Individual AWS Services (parallel)
   - audit-log-aggregator
   - employee-management-api
   - project-management-system
   - php-rest-api
   - calculator-app (Amplify)
   ↓
3. Azure (independent)
   - mortgage-calculator
```

## Step-by-Step Deployment

### 1. Configure Remote State (Recommended)

Before deploying, set up remote state storage:

#### AWS S3 Backend

```bash
# Create S3 bucket for state
aws s3 mb s3://your-terraform-state-bucket --region us-east-1

# Create DynamoDB table for locking
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

Then uncomment and update the backend configuration in each project's `main.tf`.

### 2. Deploy AWS Shared Infrastructure

```bash
cd aws/projects/shared-infrastructure

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize and deploy
terraform init
terraform plan
terraform apply
```

Save the outputs - you'll need them for service deployments:

```bash
terraform output > ../shared-outputs.txt
```

### 3. Deploy Individual AWS Services

Each service follows the same pattern:

```bash
cd aws/projects/audit-log-aggregator

# Initialize
terraform init

# Review changes
terraform plan

# Deploy
terraform apply
```

Repeat for:
- `employee-management-api`
- `project-management-system`
- `php-rest-api`
- `calculator-app`

### 4. Deploy Azure Resources

```bash
cd azure/projects/mortgage-calculator

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars

# Initialize
terraform init

# Deploy
terraform apply
```

## Verification

### AWS Services

```bash
# Get ALB DNS name
cd aws/projects/shared-infrastructure
export ALB_DNS=$(terraform output -raw alb_dns_name)

# Test endpoints
curl http://$ALB_DNS/audit/health
curl http://$ALB_DNS/employees/health
curl http://$ALB_DNS/projects/health
curl http://$ALB_DNS/php/health
```

### Azure Service

```bash
cd azure/projects/mortgage-calculator
export APP_URL=$(terraform output -raw app_url)

curl $APP_URL/health
```

## Updating Services

### Update Container Image

1. Build and push new image
2. Update `container_image` variable or use `latest` tag
3. Run `terraform apply`

### Scale Services

Edit variables and apply:

```hcl
# In terraform.tfvars
desired_count            = 2
enable_autoscaling       = true
autoscaling_max_capacity = 4
```

```bash
terraform apply
```

## Destroying Resources

**Warning**: This will delete all resources!

```bash
# Destroy in reverse order

# 1. Individual services
cd aws/projects/audit-log-aggregator && terraform destroy
cd aws/projects/employee-management-api && terraform destroy
# ... etc

# 2. Shared infrastructure (last)
cd aws/projects/shared-infrastructure && terraform destroy

# 3. Azure
cd azure/projects/mortgage-calculator && terraform destroy
```

## Cost Management

### Development Environment

Use these settings to minimize costs:

```hcl
# AWS
single_nat_gateway = true
enable_container_insights = false

# ECS Services
desired_count = 1
enable_autoscaling = false

# Azure
min_replicas = 0  # Scale to zero
```

### Estimated Monthly Costs

| Environment | AWS | Azure | Total |
|-------------|-----|-------|-------|
| Dev (minimal) | ~$50 | ~$5 | ~$55 |
| Production | ~$150 | ~$20 | ~$170 |

### Cost-Saving Tips

1. **Destroy when not in use**: For demos, deploy → show → destroy
2. **Use FARGATE_SPOT**: Up to 70% savings on ECS
3. **Scale to zero on Azure**: Container Apps can scale to 0
4. **Single NAT Gateway**: Use for dev/staging
5. **Reserved capacity**: For long-running production

## Troubleshooting

### Common Issues

**ECS tasks failing to start**
```bash
# Check logs
aws logs tail /ecs/portfolio-dev/audit-log-aggregator --follow
```

**ALB health checks failing**
```bash
# Verify security groups allow traffic
# Check container is listening on correct port
# Verify health check path returns 200
```

**Azure Container App not accessible**
```bash
# Check ingress configuration
az containerapp show --name mortgage-calculator --resource-group portfolio-dev-rg
```

### Getting Help

1. Check CloudWatch/Log Analytics logs
2. Verify security groups and network configuration
3. Review Terraform state: `terraform show`
4. Check AWS/Azure console for resource status
