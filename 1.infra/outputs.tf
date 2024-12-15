# Output

output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "vm_virtual_network" {
  value = azurerm_virtual_network.vm_network.name
}

output "vm_subnet" {
  value = azurerm_subnet.vm_subnet.name
}

#output "jenkins_IP_address" {
#  value = azurerm_network_interface.jenkins_nic.ip_configuration[0].public_ip_address_id
#}

output "jenkins_public_ip_address" {
  value = azurerm_linux_virtual_machine.jenkins_vm.public_ip_address
}

# KV output
output "azurerm_key_vault_name" {
  value = azurerm_key_vault.vault.name
}

output "azurerm_key_vault_id" {
  value = azurerm_key_vault.vault.id
}

# AKS
output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

# ACR
output "acr_login_server" {
  description = "The URL of the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_username" {
  description = "The admin username  of the Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_password" {
  description = "The admin password of the Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}
