#!/usr/bin/env bash
# import.sh - Adopt existing Azure resources into Terraform state.
#
# Run this ONCE after `terraform init` and before `terraform plan`.
# It tells Terraform to manage the resources that were created manually
# instead of trying to create new ones alongside them.
#
# Prerequisites:
#   - terraform init has been run
#   - terraform.tfvars exists with subscription_id and admin_ssh_public_key
#   - You are logged in via `az login`

set -e

SUB="51295ddb-b64f-44e5-8c18-5ba00d62815b"
RG="netiks-rg"

echo "Importing resource group..."
terraform import azurerm_resource_group.main \
  "/subscriptions/${SUB}/resourceGroups/${RG}"

echo "Importing virtual network..."
terraform import module.networking.azurerm_virtual_network.main \
  "/subscriptions/${SUB}/resourceGroups/${RG}/providers/Microsoft.Network/virtualNetworks/vnet-southafricanorth-1"

echo "Importing subnet..."
terraform import module.networking.azurerm_subnet.main \
  "/subscriptions/${SUB}/resourceGroups/${RG}/providers/Microsoft.Network/virtualNetworks/vnet-southafricanorth-1/subnets/snet-southafricanorth-1"

echo "Importing NSG..."
terraform import module.networking.azurerm_network_security_group.main \
  "/subscriptions/${SUB}/resourceGroups/${RG}/providers/Microsoft.Network/networkSecurityGroups/netiks-vm-nsg"

echo "Importing public IP..."
terraform import module.networking.azurerm_public_ip.main \
  "/subscriptions/${SUB}/resourceGroups/${RG}/providers/Microsoft.Network/publicIPAddresses/netiks-vm-ip"

echo "Importing NIC..."
terraform import module.compute.azurerm_network_interface.main \
  "/subscriptions/${SUB}/resourceGroups/${RG}/providers/Microsoft.Network/networkInterfaces/netiks-vm826"

echo "Importing VM..."
terraform import module.compute.azurerm_linux_virtual_machine.main \
  "/subscriptions/${SUB}/resourceGroups/${RG}/providers/Microsoft.Compute/virtualMachines/netiks-vm"

echo "Importing ACR..."
terraform import module.registry.azurerm_container_registry.main \
  "/subscriptions/${SUB}/resourceGroups/${RG}/providers/Microsoft.ContainerRegistry/registries/wisdomnetiks"

echo ""
echo "All imports complete. Run 'terraform plan' to verify no unintended changes."
