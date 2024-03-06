resource "azurerm_resource_group" "acr_rg" {
  name     = "SME-${var.alias}-ACR-2"
  location = var.location
}