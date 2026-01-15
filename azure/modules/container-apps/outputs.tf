# ------------------------------------------------------------------------------
# Azure Container Apps Outputs
# ------------------------------------------------------------------------------

output "container_app_id" {
  description = "ID of the container app"
  value       = azurerm_container_app.main.id
}

output "container_app_name" {
  description = "Name of the container app"
  value       = azurerm_container_app.main.name
}

output "environment_id" {
  description = "ID of the Container Apps environment"
  value       = azurerm_container_app_environment.main.id
}

output "environment_name" {
  description = "Name of the Container Apps environment"
  value       = azurerm_container_app_environment.main.name
}

output "fqdn" {
  description = "Fully qualified domain name"
  value       = azurerm_container_app.main.ingress[0].fqdn
}

output "url" {
  description = "HTTPS URL of the container app"
  value       = "https://${azurerm_container_app.main.ingress[0].fqdn}"
}

output "latest_revision_name" {
  description = "Name of the latest revision"
  value       = azurerm_container_app.main.latest_revision_name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}
