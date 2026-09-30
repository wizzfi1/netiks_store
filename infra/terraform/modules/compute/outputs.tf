output "vm_id" {
  value = azurerm_linux_virtual_machine.main.id
}

output "vm_principal_id" {
  description = "The system-assigned managed identity principal ID (used for ACR role assignment)."
  value       = azurerm_linux_virtual_machine.main.identity[0].principal_id
}

output "private_ip_address" {
  value = azurerm_network_interface.main.private_ip_address
}

output "nic_id" {
  value = azurerm_network_interface.main.id
}
