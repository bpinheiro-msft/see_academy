##AKS UAMI
resource "azurerm_user_assigned_identity" "uami" {
  location            = azurerm_resource_group.acr_rg.location
  name                = "sme_aks_${var.alias}_uami"
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_role_assignment" "vnet_aks_network_contributor" {
  scope                = azurerm_resource_group.acr_rg.id
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

#PUSHVM UAMI
resource "azurerm_user_assigned_identity" "push_uami" {
  location            = azurerm_resource_group.acr_rg.location
  name                = "PushUAMI"
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_role_assignment" "acr_acrpull_push_vm" {
  principal_id         = azurerm_user_assigned_identity.push_uami.principal_id
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "acrpull"
}

resource "azurerm_role_assignment" "acr_acrpush_push_vm" {
  principal_id         = azurerm_user_assigned_identity.push_uami.principal_id
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "acrpush"
}

resource "azurerm_role_assignment" "acr_acrimagesigner_push_vm" {
  principal_id         = azurerm_user_assigned_identity.push_uami.principal_id
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "acrimagesigner"
}