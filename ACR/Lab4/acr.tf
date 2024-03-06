resource "azurerm_container_registry" "acr" {
  name                          = "sme${var.alias}acrhw2"
  resource_group_name           = azurerm_resource_group.acr_rg.name
  location                      = azurerm_resource_group.acr_rg.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = true
}