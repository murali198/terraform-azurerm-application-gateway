terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstatedev"
    container_name       = "tfstateagiccontainer"
    key                  = "tfstate/agicstate"
  }
}
