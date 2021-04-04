resource "azurerm_resource_group" "frontend-rg" {
  name     = "frontendrg"
  location = "East US"
}

module "frontendvnet" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = "${var.env}-frontend-vnet"
  resource_group_name = azurerm_resource_group.frontend-rg.name
  address_space       = ["10.0.0.0/23"]
  subnet_prefixes     = ["10.0.0.0/24", "10.0.1.0/24"]
  subnet_names        = ["AzureFirewallSubnet", "${var.env}-frontendjboxsnet"]
  tags                = null
}

# resource "azurerm_virtual_network" "frontend-vnet" {
#   name                = "frontendvnet"
#   address_space       = ["10.0.0.0/23"]
#   location            = azurerm_resource_group.frontend-rg.location
#   resource_group_name = azurerm_resource_group.frontend-rg.name
# }

# resource "azurerm_subnet" "frontend-firewall-snet" {
#   name                 = "AzureFirewallSubnet"
#   resource_group_name  = azurerm_resource_group.frontend-rg.name
#   virtual_network_name = azurerm_virtual_network.frontend-vnet.name
#   address_prefixes     = ["10.0.0.0/24"]
# }

# resource "azurerm_subnet" "frontend-jbox-snet" {
#   name                 = "frontendjboxsnet"
#   resource_group_name  = azurerm_resource_group.frontend-rg.name
#   virtual_network_name = azurerm_virtual_network.frontend-vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

resource "azurerm_public_ip" "frontend-pip" {
  name                = "${var.env}-frontendpip"
  location            = azurerm_resource_group.frontend-rg.location
  resource_group_name = azurerm_resource_group.frontend-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "frontend-firewall" {
  name                = "${var.env}-frontendfirewall"
  location            = azurerm_resource_group.frontend-rg.location
  resource_group_name = azurerm_resource_group.frontend-rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.frontendvnet.vnet_subnets[0]
    public_ip_address_id = azurerm_public_ip.frontend-pip.id
  }
}