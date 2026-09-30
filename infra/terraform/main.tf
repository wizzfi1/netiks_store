terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  subnet_name         = var.subnet_name
  subnet_prefix       = var.subnet_prefix
  nsg_name            = var.nsg_name
  public_ip_name      = var.public_ip_name
}

module "compute" {
  source = "./modules/compute"

  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  vm_name              = var.vm_name
  vm_size              = var.vm_size
  admin_username       = var.admin_username
  admin_ssh_public_key = var.admin_ssh_public_key
  nic_name             = var.nic_name
  subnet_id            = module.networking.subnet_id
  public_ip_id         = module.networking.public_ip_id
  nsg_id               = module.networking.nsg_id
  os_disk_size_gb      = var.os_disk_size_gb

  depends_on = [module.networking]
}

module "registry" {
  source = "./modules/registry"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  registry_name       = var.registry_name
  sku                 = var.registry_sku
  vm_principal_id     = module.compute.vm_principal_id

  depends_on = [module.compute]
}
