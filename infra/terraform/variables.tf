variable "subscription_id" {
  type        = string
  description = "Azure subscription ID."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group."
  default     = "netiks-rg"
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "southafricanorth"
}

# Networking
variable "vnet_name" {
  type    = string
  default = "vnet-southafricanorth-1"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["172.16.0.0/16"]
}

variable "subnet_name" {
  type    = string
  default = "snet-southafricanorth-1"
}

variable "subnet_prefix" {
  type    = string
  default = "172.16.0.0/24"
}

variable "nsg_name" {
  type    = string
  default = "netiks-vm-nsg"
}

variable "public_ip_name" {
  type    = string
  default = "netiks-vm-ip"
}

# Compute
variable "vm_name" {
  type    = string
  default = "netiks-vm"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2as_v2"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key content for the VM admin user."
  sensitive   = true
}

variable "nic_name" {
  type    = string
  default = "netiks-vm826"
}

variable "os_disk_size_gb" {
  type    = number
  default = 30
}

# Registry
variable "registry_name" {
  type    = string
  default = "wisdomnetiks"
}

variable "registry_sku" {
  type    = string
  default = "Basic"
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "CIDR range allowed to SSH into the VM. Set this to your office or home IP, e.g. 41.58.x.x/32."
}
