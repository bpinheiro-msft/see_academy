resource "azurerm_user_assigned_identity" "uami" {
  location            = azurerm_resource_group.core_rg.location
  name                = "sme_aks_${var.alias}_uami"
  resource_group_name = azurerm_resource_group.core_rg.name
}

resource "azurerm_role_assignment" "aks_dns_role" {
  scope                = azurerm_private_dns_zone.aks_zone.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

resource "azurerm_role_assignment" "acr_dns_role" {
  scope                = azurerm_private_dns_zone.acr_zone.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

resource "azurerm_role_assignment" "vnet_aks_network_contributor" {
  scope                = azurerm_virtual_network.sme_vnet_aks.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "acrpull"
  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_container_registry.acr
  ]
}

resource "azurerm_role_assignment" "appgateway_aksrg_contributor" {
  scope                = azurerm_resource_group.netcore_rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
