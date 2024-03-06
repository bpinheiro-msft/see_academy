resource "azurerm_public_ip" "appgw_pip" {
  name                = "sme_${var.alias}_appgw_pip"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  backend_address_pool_name      = "sme_${var.alias}_appgw_aks_beap"
  frontend_port_name             = "sme_${var.alias}_appgw_aks_feport"
  frontend_ip_configuration_name = "sme_${var.alias}_appgw_aks_feip"
  http_setting_name              = "sme_${var.alias}_appgw_aks_be_htst"
  listener_name                  = "sme_${var.alias}_appgw_aks_httplstn"
  request_routing_rule_name      = "sme_${var.alias}_appgw_aks_rqrt"
  redirect_configuration_name    = "sme_${var.alias}_appgw_aks_rdrcfg"
}

resource "azurerm_application_gateway" "application_gateway" {
  name                = "sme_${var.alias}_appgw"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "sme_${var.alias}_appgw_ip_configuration"
    subnet_id = azurerm_subnet.sme_appgw_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

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

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

}