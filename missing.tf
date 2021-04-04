resource "azurerm_virtual_network_peering" "frontend-backend" {
  name                      = "${var.env}-frontendbackend"
  resource_group_name       = azurerm_resource_group.frontend-rg.name
  virtual_network_name      = module.frontendvnet.vnet_name
  remote_virtual_network_id = module.backendvnet.vnet_id
}

resource "azurerm_virtual_network_peering" "backend-frontend" {
  name                      = "${var.env}-backendfrontend"
  resource_group_name       = azurerm_resource_group.backend-rg.name
  virtual_network_name      = module.backendvnet.vnet_name
  remote_virtual_network_id = module.frontendvnet.vnet_id
}

resource "azurerm_network_security_rule" "jbox-rdp-sr" {
  name                        = "rdp"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "${module.jumpbox-vm.private_ip_address}/32"
  destination_address_prefix  = "${azurerm_network_interface.backend-nic.private_ip_address}/32"
  resource_group_name         = azurerm_resource_group.backend-rg.name
  network_security_group_name = azurerm_network_security_group.backend-sg.name
}

resource "azurerm_firewall_nat_rule_collection" "frontend-rg" {
  name                = "nat01"
  azure_firewall_name = azurerm_firewall.frontend-firewall.name
  resource_group_name = azurerm_resource_group.frontend-rg.name
  priority            = 100
  action              = "Dnat"
  rule {
    name = "web-rule"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "80",
    ]
    destination_addresses = [
      azurerm_public_ip.frontend-pip.ip_address
    ]
    translated_port    = 80
    translated_address = azurerm_network_interface.backend-nic.private_ip_address
    protocols = [
      "TCP",
    ]
  }
  rule {
    name = "jbox-rule"
    source_addresses = [
      "*",
    ]
    destination_ports = [
      "3389",
    ]
    destination_addresses = [
      azurerm_public_ip.frontend-pip.ip_address
    ]
    translated_port    = 3389
    translated_address = module.jumpbox-vm.private_ip_address
    protocols = [
      "TCP",
    ]
  }
}