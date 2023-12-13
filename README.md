# Azure Application Gateway
This Terraform module to manage Microsoft [Azure Application Gateway] (https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) resource.

### Versioning Rule For This Modules

| Module version | Terraform version |
| -------------- | ----------------- |
| < 1.x.x        | ~> 2.46       |


### Usage

There're some examples in the examples folder. You can execute terraform apply command in examples's sub folder to try the module.

```hcl-terraform

provider "azurerm" {
  features {}

}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.46"
    }
  }
  required_version = ">= 0.12"
}

module "agic" {
  source  = "murali198/application-gateway/azurerm"
  rg_name                   = var.rg_name
  vnet_name                 = var.vnet_name
  tags                      = var.tags
  gateway_address_prefixes  = var.gateway_address_prefixes
  aks_name                  = var.aks_name
}
```

### Inputs

| Name                        | Description                                                                      | Type          | Required | Default                           |
|-----------------------------|----------------------------------------------------------------------------------|---------------|----------|-----------------------------------|
| rg_name                     | The name of the resource group in which to the Application Gateway should exist. | string        | yes      | NA                                |
| tags                        | A mapping of tags to assign to the resource.                                     | string        | no       | {}                                |
| location                    | The Azure region where the Application Gateway should exist.                     | string        | yes      | NA                                |
| gateway_subnet_name         | The name of the Subnet                                                           | strings       | no       | gateway-subnet                    |
| gateway_address_prefixes    | Specifies the name of the Subnet for gateway address prefix                      | strings       | yes      | NA                                |
| gateway_service_endpoints   | List of service endpoints that the gateway needs access to                       | list(strings) | no       | Microsoft.Sql, Microsoft.KeyVault |
| gateway_name                | Specifies the name of the gateway                                                | strings       | no       | my-agic-gateway                   |
| vnet_name                   | Specifies the name of the Virtual Network this Subnet is located within          | strings       | yes      | NA                                |
| aks_name                    | Specifies the name of the aks cluster to attach agic                             | strings       | yes      | NA                                |
| agic_identity_name          | Specifies the name of identity                                                   | strings       | no       | my-agic-identity                  |
| agic_ingress_ip             | Specifies the name of the ip address                                             | strings       | no       | my-agic-ingress-ip                |
| agic_gateway_ip_config_name | Specifies the name of the ip config                                              | strings       | no       | my-gateway-ip-configuration       |
