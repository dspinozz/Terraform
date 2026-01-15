# ------------------------------------------------------------------------------
# Azure Container Apps Module
# Creates a Container Apps environment and container app
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Log Analytics Workspace (required for Container Apps)
# ------------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Container Apps Environment
# ------------------------------------------------------------------------------

resource "azurerm_container_app_environment" "main" {
  name                       = "${var.name}-env"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Container App
# ------------------------------------------------------------------------------

resource "azurerm_container_app" "main" {
  name                         = var.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode

  template {
    container {
      name   = var.container_name != "" ? var.container_name : var.name
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secret_environment_variables
        content {
          name        = env.key
          secret_name = env.value
        }
      }

      dynamic "liveness_probe" {
        for_each = var.enable_health_probes ? [1] : []
        content {
          transport        = "HTTP"
          path             = var.health_check_path
          port             = var.container_port
          initial_delay    = var.health_probe_initial_delay
          interval_seconds = var.health_probe_interval
          timeout          = var.health_probe_timeout
        }
      }

      dynamic "readiness_probe" {
        for_each = var.enable_health_probes ? [1] : []
        content {
          transport        = "HTTP"
          path             = var.health_check_path
          port             = var.container_port
          interval_seconds = var.health_probe_interval
          timeout          = var.health_probe_timeout
        }
      }
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    dynamic "http_scale_rule" {
      for_each = var.enable_http_scaling ? [1] : []
      content {
        name                = "http-scaling"
        concurrent_requests = var.http_scale_concurrent_requests
      }
    }
  }

  ingress {
    external_enabled = var.external_ingress
    target_port      = var.container_port
    transport        = "http"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  dynamic "secret" {
    for_each = var.secrets
    content {
      name  = secret.key
      value = secret.value
    }
  }

  dynamic "registry" {
    for_each = var.container_registry_server != "" ? [1] : []
    content {
      server               = var.container_registry_server
      username             = var.container_registry_username
      password_secret_name = var.container_registry_password_secret_name
    }
  }

  tags = var.tags
}
