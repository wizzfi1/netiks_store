variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group."
}

variable "location" {
  type        = string
  description = "Azure region for all networking resources."
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network."
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network."
  default     = ["172.16.0.0/16"]
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet."
}

variable "subnet_prefix" {
  type        = string
  description = "CIDR prefix for the subnet."
  default     = "172.16.0.0/24"
}

variable "nsg_name" {
  type        = string
  description = "Name of the network security group."
}

variable "public_ip_name" {
  type        = string
  description = "Name of the public IP address resource."
}
