# ------------------------------------------------------------------------------
# Azure Resource Group Module
# Creates a resource group with proper tagging
# ------------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = var.name
  location = var.location

  tags = merge(var.tags, {
    ManagedBy = "terraform"
  })
}
