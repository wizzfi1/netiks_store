output "vm_public_ip" {
  description = "Public IP address of the VM."
  value       = module.networking.public_ip_address
}

output "acr_login_server" {
  description = "ACR login server hostname for docker login and image tags."
  value       = module.registry.login_server
}

output "vm_principal_id" {
  description = "Managed identity principal ID of the VM (used for ACR pull)."
  value       = module.compute.vm_principal_id
}
