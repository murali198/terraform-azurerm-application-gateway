variable "rg_name" {
  description = "The name of the resource group in which to create the Application Gateway"
  type        = string
}

variable "location" {
  description = "The location to deploy resources to."
  default     = "centralus"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the resources"
  default     = {}
}

variable "gateway_subnet_name" {
  description = "Specifies the name of the Subnet for gateway"
  type        = string
  default     = "gateway-subnet"
}

variable "gateway_address_prefixes" {
  description = "Specifies the name of the Subnet for gateway address prefix"
  type        = string
}

variable "gateway_service_endpoints" {
  description = "List of service endpoints that the gateway needs access to"
  default = [
    "Microsoft.Sql",
    "Microsoft.KeyVault"
  ]
}

variable "gateway_name" {
  description = "Specifies the name of the Subnet for gateway"
  type        = string
  default     = null
}

variable "vnet_name" {
  description = "Specifies the name of the Virtual Network this Subnet is located within"
  type        = string
}

variable "aks_name" {
  description = "Specifies the name of the aks cluster to attach agic"
  type        = string
}

variable "agic_identity_name" {
  description = "Specifies the name of identity"
  type        = string
  default     = null
}

variable "agic_ingress_ip" {
  description = "Specifies the name of identity"
  type        = string
  default     = null
}

variable "agic_gateway_ip_config_name" {
  description = "Specifies the name of identity"
  type        = string
  default     = null
}
