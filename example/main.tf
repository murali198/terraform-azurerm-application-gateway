provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

module "agic" {
  source                    = "../"
  rg_name                   = var.rg_name
  vnet_name                 = var.vnet_name
  tags                      = var.tags
  gateway_address_prefixes  = var.gateway_address_prefixes
  aks_name                  = var.aks_name
}



