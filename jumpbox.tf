resource "azurerm_resource_group" "jumpbox-rg" {
  name     = "jumpboxrg"
  location = "East US"
}

module "jumpbox-vm" {
  source    = "./modules/compute"
  location  = azurerm_resource_group.jumpbox-rg.location
  rgname    = azurerm_resource_group.jumpbox-rg.name
  vmname    = "${var.env}-jumpBox-vm01"
  subnet_id = module.frontendvnet.vnet_subnets[1]
}

resource "azurerm_network_security_rule" "jumpbox-sr" {
  name                        = "${var.env}-jumpboxnsr"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "${module.jumpbox-vm.private_ip_address}/32"
  resource_group_name         = azurerm_resource_group.jumpbox-rg.name
  network_security_group_name = module.jumpbox-vm.sg_name
}

resource "azurerm_network_interface_security_group_association" "jbox-rg" {
  network_interface_id      = module.jumpbox-vm.nic_id
  network_security_group_id = module.jumpbox-vm.sg_id
}