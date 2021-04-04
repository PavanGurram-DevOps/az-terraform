resource "azurerm_resource_group" "jumpbox-rg" {
  name     = "jumpboxrg"
  location = "East US"
}

module "jumpbox-vm" {
source = "./modules/compute"
location = azurerm_resource_group.jumpbox-rg.location
rgname = azurerm_resource_group.jumpbox-rg.name
vmname = "${var.jumpBox}-vm01"
subnet_id = azurerm_subnet.frontend-jbox-snet.id
}


# module.jumpbox-vm.private_ip_address
# module.jumpbox-vm.sg_name
# module.jumpbox-vm.nic_id
# module.jumpbox-vm.sg_id
# module.jumpbox-vm.vm_id

/*resource "azurerm_network_interface" "jumpbox-nic" {
  name                = "jumpboxnic"
  location            = azurerm_resource_group.jumpbox-rg.location
  resource_group_name = azurerm_resource_group.jumpbox-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.frontend-jbox-snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "jumpbox-sg" {
  name                = "jumpboxsg"
  location            = azurerm_resource_group.jumpbox-rg.location
  resource_group_name = azurerm_resource_group.jumpbox-rg.name
}*/

resource "azurerm_network_security_rule" "jumpbox-sr" {
  name                        = "jumpboxnsr"
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

/*resource "azurerm_virtual_machine" "jbox-vm" {
  name                  = "${var.jumpBox}-vm01"
  location              = azurerm_resource_group.jumpbox-rg.location
  resource_group_name   = azurerm_resource_group.jumpbox-rg.name
  network_interface_ids = [azurerm_network_interface.jumpbox-nic.id]
  vm_size               = "Standard_B2s"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.jumpBox}-osdisk"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "${var.jumpBox}-vm01"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }
  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true
  }
}*/