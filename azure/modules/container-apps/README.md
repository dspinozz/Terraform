# Azure Container Apps Module

Creates an Azure Container Apps environment and container app with auto-scaling, health probes, and ingress configuration.

## Features

- Container Apps environment with Log Analytics
- Container app with configurable resources
- HTTP-based auto-scaling
- Health probes (liveness and readiness)
- External ingress with HTTPS
- Environment variables and secrets
- Container registry integration

## Usage

```hcl
module "container_app" {
  source = "../../modules/container-apps"

  name                = "my-app"
  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus"

  container_image = "ghcr.io/dspinozz/my-app:latest"
  container_port  = 8080
  cpu             = 0.25
  memory          = "0.5Gi"

  environment_variables = {
    APP_ENV = "production"
  }

  min_replicas = 0
  max_replicas = 3

  enable_health_probes = true
  health_check_path    = "/health"

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the container app | string | - | yes |
| resource_group_name | Resource group name | string | - | yes |
| container_image | Docker image | string | - | yes |
| location | Azure region | string | "eastus" | no |
| container_port | Container port | number | 8080 | no |
| cpu | CPU cores | number | 0.25 | no |
| memory | Memory (e.g., "0.5Gi") | string | "0.5Gi" | no |
| min_replicas | Minimum replicas | number | 0 | no |
| max_replicas | Maximum replicas | number | 3 | no |

## Outputs

| Name | Description |
|------|-------------|
| container_app_id | Container app ID |
| fqdn | Fully qualified domain name |
| url | HTTPS URL |
| latest_revision_name | Latest revision name |

## Scaling

Container Apps scale based on:
- **HTTP requests**: Configurable concurrent requests threshold
- **Replicas**: Scale between min and max replicas
- **Scale to zero**: Set min_replicas = 0 for cost savings

## Cost Optimization

- **Scale to zero**: Set min_replicas = 0 for dev/staging
- **Consumption pricing**: Pay only for resources used
- **Free tier**: First 180,000 vCPU-seconds/month are free
