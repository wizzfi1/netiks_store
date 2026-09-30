variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group."
}

variable "location" {
  type        = string
  description = "Azure region for the container registry."
}

variable "registry_name" {
  type        = string
  description = "Name of the Azure Container Registry (globally unique, alphanumeric only)."
}

variable "sku" {
  type        = string
  description = "ACR pricing tier: Basic, Standard, or Premium."
  default     = "Basic"
}

variable "vm_principal_id" {
  type        = string
  description = "Principal ID of the VM managed identity, granted AcrPull on this registry."
}
