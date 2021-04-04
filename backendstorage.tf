terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-rg"
    storage_account_name = "remotestorageaccounttest"
    container_name       = "tfstate"
    key                  = "backendStorage.tfstate"
  }
}