locals {
  backend_address_pool_name      = "${var.vnet_name}-agic-beap"
  frontend_port_name             = "${var.vnet_name}-agic-feport"
  frontend_secure_port_name      = "${var.vnet_name}-agic-secure-feport"
  frontend_ip_configuration_name = "${var.vnet_name}-agic-feip"
  http_setting_name              = "${var.vnet_name}-agic-be-htst"
  listener_name                  = "${var.vnet_name}-agic-httplstn"
  request_routing_rule_name      = "${var.vnet_name}-agic-rqrt"
  redirect_configuration_name    = "${var.vnet_name}-agic-rdrcfg"
}

resource "azurerm_user_assigned_identity" "agic_identity" {
  resource_group_name = var.rg_name
  location            = var.location
  name                = var.agic_identity_name
  tags                = var.tags
}

resource "azurerm_public_ip" "aks_ingress_public_ip" {
  name                = var.agic_ingress_ip
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_subnet" "appgateway_subnet" {
  name                 = var.gateway_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rg_name
  address_prefixes     = [var.gateway_address_prefixes]
  service_endpoints    = var.gateway_service_endpoints
}

resource "azurerm_network_security_group" "appgwsubnet_nsg" {
  name                = "${var.gateway_subnet_name}-nsg"
  resource_group_name = var.rg_name
  location            = var.location
  security_rule = [
    {
      name                                       = "AllowInternetClients"
      description                                = "Allow TLS/443 Inbound"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "443"
      source_address_prefix                      = "Internet"
      destination_address_prefix                 = "*"
      access                                     = "Allow"
      priority                                   = "3800"
      direction                                  = "Inbound"
      source_port_ranges                         = []
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      destination_port_ranges                    = []
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
    },
    {
      name                                       = "AllowGatewayManager"
      description                                = "Requied AppGateway NSG Rule"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "65200-65535"
      source_address_prefix                      = "GatewayManager"
      destination_address_prefix                 = "*"
      access                                     = "Allow"
      priority                                   = "3900"
      direction                                  = "Inbound"
      source_port_ranges                         = []
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      destination_port_ranges                    = []
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
    },
    {
      name                                       = "AllowVNETTraffic"
      description                                = "Requied AppGateway NSG Rule"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "*"
      source_address_prefix                      = "VirtualNetwork"
      destination_address_prefix                 = "*"
      access                                     = "Allow"
      priority                                   = "3850"
      direction                                  = "Inbound"
      source_port_ranges                         = []
      source_address_prefixes                    = []
      source_application_security_group_ids      = []
      destination_port_ranges                    = []
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
    }

  ]
}

resource "azurerm_subnet_network_security_group_association" "appgw_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.appgateway_subnet.id
  network_security_group_id = azurerm_network_security_group.appgwsubnet_nsg.id

  depends_on = [
    azurerm_subnet.appgateway_subnet,
    azurerm_network_security_group.appgwsubnet_nsg
  ]
}

resource "azurerm_application_gateway" "aks_ingress_gateway" {
  name                = var.gateway_name
  resource_group_name = var.rg_name
  location            = var.location
  tags                = var.tags
  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.aks_ingress_public_ip.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = local.frontend_secure_port_name
    port = 443
  }

  gateway_ip_configuration {
    name      = var.agic_gateway_ip_config_name
    subnet_id = azurerm_subnet.appgateway_subnet.id
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agic_identity.id]
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 125
  }

  ssl_policy {
    policy_type          = "Custom"
    min_protocol_version = "TLSv1_2"
    cipher_suites = [
      "TLS_RSA_WITH_AES_256_CBC_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384",
      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
      "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_RSA_WITH_AES_128_CBC_SHA256"
    ]
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "prevention"
    rule_set_type    = "OWASP"
    rule_set_version = 3.1
  }

  lifecycle {
    ignore_changes = [
      frontend_port,
      backend_address_pool,
      backend_http_settings,
      http_listener,
      url_path_map,
      request_routing_rule,
      probe,
      redirect_configuration,
      tags,
    ]
  }

  depends_on = [
    azurerm_network_security_group.appgwsubnet_nsg
  ]
}

data "azurerm_resource_group" "main" {
  name       = var.rg_name
}

data "azurerm_user_assigned_identity" "ingress_controller_pod_identity" {
  name                = "ingressapplicationgateway-${var.aks_name}"
  resource_group_name = "MC_${var.rg_name}_${var.aks_name}_${var.location}"
  depends_on = [
    azurerm_application_gateway.aks_ingress_gateway
  ]
}

resource "azurerm_role_assignment" "role_agw" {
  scope                = azurerm_application_gateway.aks_ingress_gateway.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.ingress_controller_pod_identity.principal_id
}

resource "azurerm_role_assignment" "role_rg" {
  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_user_assigned_identity.ingress_controller_pod_identity.principal_id
}

resource "azurerm_role_assignment" "role_mi_rg" {
  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = data.azurerm_user_assigned_identity.ingress_controller_pod_identity.principal_id
}