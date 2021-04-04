output "private_ip_address" {
  value = azurerm_network_interface.compute.private_ip_address
}

output "sg_name" {
  value = azurerm_network_security_group.compute.name
}

output "sg_id" {
  value = azurerm_network_security_group.compute.id
}

output "nic_id" {
  value = azurerm_network_interface.compute.id
}

output "vm_id" {
  value = azurerm_virtual_machine.compute.id
}