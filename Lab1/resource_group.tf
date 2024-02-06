resource "azurerm_resource_group" "netcore_rg" {
  name     = var.netcore_rg
  location = var.location
}

resource "azurerm_resource_group" "core_rg" {
  name     = var.core_rg
  location = var.location
}

resource "azurerm_resource_group" "aks_rg" {
  name     = var.aks_rg
  location = var.location
}