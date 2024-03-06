resource "azurerm_resource_group" "acr_rg" {
  name     = var.rg
  location = var.location
}