# ------------------------------------------------------------------------------
# Mortgage Calculator Outputs
# ------------------------------------------------------------------------------

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "container_app_name" {
  description = "Name of the container app"
  value       = module.container_app.container_app_name
}

output "app_url" {
  description = "URL of the mortgage calculator"
  value       = module.container_app.url
}

output "fqdn" {
  description = "Fully qualified domain name"
  value       = module.container_app.fqdn
}

output "environment_name" {
  description = "Container Apps environment name"
  value       = module.container_app.environment_name
}

output "summary" {
  description = "Quick reference"
  value = {
    url             = module.container_app.url
    resource_group  = module.resource_group.name
    location        = module.resource_group.location
  }
}
