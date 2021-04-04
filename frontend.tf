resource "azurerm_resource_group" "frontend-rg" {
  name     = "frontendrg"
  location = "East US"
}

resource "azurerm_virtual_network" "frontend-vnet" {
  name                = "frontendvnet"
  address_space       = ["10.0.0.0/23"]
  location            = azurerm_resource_group.frontend-rg.location
  resource_group_name = azurerm_resource_group.frontend-rg.name
}

resource "azurerm_subnet" "frontend-firewall-snet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.frontend-rg.name
  virtual_network_name = azurerm_virtual_network.frontend-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "frontend-jbox-snet" {
  name                 = "frontendjboxsnet"
  resource_group_name  = azurerm_resource_group.frontend-rg.name
  virtual_network_name = azurerm_virtual_network.frontend-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "frontend-pip" {
  name                = "frontendpip"
  location            = azurerm_resource_group.frontend-rg.location
  resource_group_name = azurerm_resource_group.frontend-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "frontend-firewall" {
  name                = "frontendfirewall"
  location            = azurerm_resource_group.frontend-rg.location
  resource_group_name = azurerm_resource_group.frontend-rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.frontend-firewall-snet.id
    public_ip_address_id = azurerm_public_ip.frontend-pip.id
  }
}