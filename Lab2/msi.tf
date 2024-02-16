resource "azurerm_user_assigned_identity" "aks_uami" {
  location            = azurerm_resource_group.aks_rg.location
  name                = "sme_aks_${var.alias}_uami"
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_role_assignment" "vnet_aks_network_contributor" {
  scope                = azurerm_virtual_network.sme_vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_uami.principal_id
}

resource "azurerm_role_assignment" "appgateway_aksrg_contributor" {
  scope                = azurerm_resource_group.aks_rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
