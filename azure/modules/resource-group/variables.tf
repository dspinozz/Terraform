# ------------------------------------------------------------------------------
# Azure Resource Group Variables
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}
