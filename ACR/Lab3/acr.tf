## Create ACR
resource "azurerm_container_registry" "acr" {
  name                          = "smeacademy${var.alias}acr"
  resource_group_name           = azurerm_resource_group.acr_rg.name
  location                      = azurerm_resource_group.acr_rg.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = false

  trust_policy {
    enabled = true
  } 

  georeplications {
    location                = "North Europe"
    zone_redundancy_enabled = true
    tags                    = {}
  }
}

## Create ACR private DNS zone
resource "azurerm_private_dns_zone" "acr_zone" {
  name                = "privatelink.${var.location}.azurecr.io"
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_vnet_hub_link" {
  name                  = "aks-private-dns-zone-vnet-link-hub"
  resource_group_name   = azurerm_resource_group.acr_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.acr_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet_acr_private.id
}

## Create ACR private endpoint
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "sme_${var.alias}_endpoint"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
  subnet_id           = azurerm_subnet.acr_subnet.id

  private_service_connection {
    name                           = "sme_${var.alias}_endpoint_private_service_connection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = azurerm_private_dns_zone.acr_zone.name
    private_dns_zone_ids = [azurerm_private_dns_zone.acr_zone.id]
  }
}

data "azurerm_network_interface" "acr_pep_nic" {
  name                = azurerm_private_endpoint.acr_private_endpoint.network_interface[0].name
  resource_group_name = azurerm_resource_group.acr_rg.name
  depends_on = [azurerm_private_endpoint.acr_private_endpoint]
}

resource "azurerm_private_dns_a_record" "acr_dns_record_geo_data" {
  name                = lower(format("%s.%s.data", azurerm_container_registry.acr.name, azurerm_container_registry.acr.georeplications[0].location))
  zone_name           = azurerm_private_dns_zone.acr_zone.name
  resource_group_name = azurerm_resource_group.acr_rg.name
  ttl                 = 3600
  records             = [data.azurerm_network_interface.acr_pep_nic.private_ip_addresses[0]]
  depends_on = [data.azurerm_network_interface.acr_pep_nic]
}

resource "azurerm_private_dns_a_record" "acr_dns_record_data" {
  name                = lower(format("%s.%s.data", azurerm_container_registry.acr.name, azurerm_container_registry.acr.location))
  zone_name           = azurerm_private_dns_zone.acr_zone.name
  resource_group_name = azurerm_resource_group.acr_rg.name
  ttl                 = 3600
  records             = [data.azurerm_network_interface.acr_pep_nic.private_ip_addresses[1]]
  depends_on = [data.azurerm_network_interface.acr_pep_nic]
}

resource "azurerm_private_dns_a_record" "acr_dns_record" {
  name                = lower(azurerm_container_registry.acr.name)
  zone_name           = azurerm_private_dns_zone.acr_zone.name
  resource_group_name = azurerm_resource_group.acr_rg.name
  ttl                 = 3600
  records             = [data.azurerm_network_interface.acr_pep_nic.private_ip_addresses[2]]
  depends_on = [data.azurerm_network_interface.acr_pep_nic]
}
