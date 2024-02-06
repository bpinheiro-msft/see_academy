## Create private AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                    = "sme_${var.alias}_aks"
  location                = azurerm_resource_group.aks_rg.location
  resource_group_name     = azurerm_resource_group.aks_rg.name
  dns_prefix              = "sme-${var.alias}-aks-dns"
  private_cluster_enabled = true
  kubernetes_version      = var.kubernetes_version
  private_dns_zone_id     = azurerm_private_dns_zone.aks_zone.id

   default_node_pool {
    name                 = "agentpool"
    node_count           = var.node_count
    vm_size              = var.vm_size
    vnet_subnet_id       = azurerm_subnet.nodes_subnet.id
    pod_subnet_id        = azurerm_subnet.pods_subnet.id
  }

  identity {
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.uami.id ] 
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.application_gateway.id
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
    dns_service_ip = "10.240.0.10"
    service_cidr   = "10.240.0.0/24"
    outbound_type  = "loadBalancer"
  }

  depends_on = [
    azurerm_route_table.aks_route_table,
    azurerm_role_assignment.aks_dns_role,
    azurerm_role_assignment.vnet_aks_network_contributor,
    azurerm_virtual_network_dns_servers.sme_vnet_aks_dns_server
  ]

}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.vm_size
  node_count            = var.node_count
  vnet_subnet_id        = azurerm_subnet.nodes_subnet.id
  pod_subnet_id         = azurerm_subnet.pods_subnet.id
}


## Create AKS private dns zone
resource "azurerm_private_dns_zone" "aks_zone" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.netcore_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks_vnet_hub_link" {
  name                  = "aks-private-dns-zone-vnet-link-hub"
  resource_group_name   = azurerm_resource_group.netcore_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_zone.name
  virtual_network_id    = azurerm_virtual_network.sme_vnet_hub.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks_vnet_aks_link" {
  name                  = "aks-private-dns-zone-vnet-link-aks"
  resource_group_name   = azurerm_resource_group.netcore_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_zone.name
  virtual_network_id    = azurerm_virtual_network.sme_vnet_aks.id
}

