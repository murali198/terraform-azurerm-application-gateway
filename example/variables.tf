variable "subscription_id" {
  description = "(Required) The prefix for the resources created in the specified Azure Resource Group"
  type        = string
}

variable "tenant_id" {
  description = "(Required) The prefix for the resources created in the specified Azure Resource Group"
  type        = string
}

variable "client_id" {
  description = "(Required) The prefix for the resources created in the specified Azure Resource Group"
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "(Required) The prefix for the resources created in the specified Azure Resource Group"
  type        = string
  default     = ""
}

variable "rg_name" {
  description = "The name of the resource group in which to create the PostgreSQL Server"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the resources"
  default     = {}
}

variable "gateway_address_prefixes" {
  description = "Specifies the name of the Subnet for gateway"
  type        = string
}

variable "vnet_name" {
  description = "Specifies the name of the Virtual Network this Subnet is located within"
  type        = string
}

variable "aks_name" {
  description = "Specifies the name of the aks cluster to attach agic"
  type        = string
}