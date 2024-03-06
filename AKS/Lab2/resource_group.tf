resource "azurerm_resource_group" "aks_rg" {
  name     = var.aks_rg
  location = var.location
}