# Output

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vm_virtual_network" {
  value = azurerm_virtual_network.vm_network.name
}

output "vm_subnet" {
  value = azurerm_subnet.vm_subnet.name
}

output "jenkins_IP_address" {
  value = azurerm_network_interface.jenkins_nic.ip_configuration[0].public_ip_address_id
}
