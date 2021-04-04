resource "azurerm_resource_group" "backend-rg" {
  name     = "backendrg"
  location = "East US"
}

resource "azurerm_virtual_network" "backend-vnet" {
  name                = "backendvnet"
  address_space       = ["10.0.2.0/23"]
  location            = azurerm_resource_group.backend-rg.location
  resource_group_name = azurerm_resource_group.backend-rg.name
}

resource "azurerm_subnet" "backend-snet" {
  name                 = "backendsnet"
  resource_group_name  = azurerm_resource_group.backend-rg.name
  virtual_network_name = azurerm_virtual_network.backend-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "backend-nic" {
  name                = "backendnic"
  location            = azurerm_resource_group.backend-rg.location
  resource_group_name = azurerm_resource_group.backend-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.backend-snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "backend-sg" {
  name                = "backendsg"
  location            = azurerm_resource_group.backend-rg.location
  resource_group_name = azurerm_resource_group.backend-rg.name
}

resource "azurerm_network_security_rule" "backend-sr" {
  name                        = "backendnsr"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "${azurerm_network_interface.backend-nic.private_ip_address}/32"
  resource_group_name         = azurerm_resource_group.backend-rg.name
  network_security_group_name = azurerm_network_security_group.backend-sg.name
}

resource "azurerm_network_interface_security_group_association" "backend-rg" {
  network_interface_id      = azurerm_network_interface.backend-nic.id
  network_security_group_id = azurerm_network_security_group.backend-sg.id
}

resource "azurerm_virtual_machine" "backend-vm" {
  name                  = "web-vm01"
  location              = azurerm_resource_group.backend-rg.location
  resource_group_name   = azurerm_resource_group.backend-rg.name
  network_interface_ids = [azurerm_network_interface.backend-nic.id]
  vm_size               = "Standard_B2s"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "web-osdisk"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "Web-vm01"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true
  }
}

resource "azurerm_virtual_machine_extension" "backend-vmext" {
  name                 = "backendvmext"
  virtual_machine_id   = azurerm_virtual_machine.backend-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings             = <<SETTINGS
    {
        "commandToExecute": "powershell Install-WindowsFeature -name Web-Server -IncludeManagementTools;"
    }
SETTINGS
}