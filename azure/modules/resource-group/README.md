# Azure Resource Group Module

Creates an Azure Resource Group with consistent tagging.

## Usage

```hcl
module "resource_group" {
  source = "../../modules/resource-group"

  name     = "my-app-rg"
  location = "eastus"

  tags = {
    Environment = "dev"
    Project     = "portfolio"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Resource group name | string | - | yes |
| location | Azure region | string | "eastus" | no |
| tags | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| name | Resource group name |
| location | Resource group location |
| id | Resource group ID |
