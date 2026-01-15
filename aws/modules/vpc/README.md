# AWS VPC Module

Creates a production-ready VPC with public and private subnets across multiple availability zones.

## Features

- Multi-AZ deployment (configurable 1-3 AZs)
- Public subnets with Internet Gateway
- Private subnets with NAT Gateway
- Cost-optimized single NAT option for dev environments
- Optional VPC Flow Logs
- Proper tagging for resource identification

## Usage

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name     = "portfolio"
  vpc_cidr = "10.0.0.0/16"
  az_count = 2

  enable_nat_gateway = true
  single_nat_gateway = true  # Use single NAT for dev (cost savings)

  enable_flow_logs = false

  tags = {
    Environment = "dev"
    Project     = "portfolio"
  }
}
```

## Subnet Layout

Given CIDR `10.0.0.0/16`:

| Subnet Type | AZ | CIDR |
|-------------|-----|------|
| Public | a | 10.0.1.0/24 |
| Public | b | 10.0.2.0/24 |
| Public | c | 10.0.3.0/24 |
| Private | a | 10.0.11.0/24 |
| Private | b | 10.0.12.0/24 |
| Private | c | 10.0.13.0/24 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name prefix for all resources | string | - | yes |
| vpc_cidr | CIDR block for the VPC | string | "10.0.0.0/16" | no |
| az_count | Number of availability zones | number | 2 | no |
| enable_nat_gateway | Create NAT gateway(s) | bool | true | no |
| single_nat_gateway | Use single NAT for all AZs | bool | true | no |
| enable_flow_logs | Enable VPC flow logs | bool | false | no |
| flow_logs_retention_days | Flow logs retention period | number | 14 | no |
| tags | Tags to apply to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr | CIDR block of the VPC |
| public_subnet_ids | IDs of public subnets |
| private_subnet_ids | IDs of private subnets |
| nat_gateway_ids | IDs of NAT gateways |
| availability_zones | List of AZs used |

## Cost Considerations

- **NAT Gateway**: ~$32/month per gateway + data processing
- **Single NAT**: Recommended for dev/staging to reduce costs
- **Multi-NAT**: Recommended for production (HA across AZs)
