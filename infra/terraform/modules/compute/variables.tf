variable "resource_group_name" {
  type        = string
  description = "Name of the Azure resource group."
}

variable "location" {
  type        = string
  description = "Azure region for the VM."
}

variable "vm_name" {
  type        = string
  description = "Name of the virtual machine."
}

variable "vm_size" {
  type        = string
  description = "Azure VM size."
  default     = "Standard_B2as_v2"
}

variable "admin_username" {
  type        = string
  description = "Administrator username for the VM."
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key for the administrator account."
  sensitive   = true
}

variable "nic_name" {
  type        = string
  description = "Name of the network interface."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to attach the NIC to."
}

variable "public_ip_id" {
  type        = string
  description = "Public IP resource ID to associate with the NIC."
}

variable "nsg_id" {
  type        = string
  description = "Network security group ID to attach to the NIC."
}

variable "os_disk_size_gb" {
  type        = number
  description = "OS disk size in GB."
  default     = 30
}
