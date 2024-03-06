## Create AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                    = "sme_${var.alias}_aks"
  location                = azurerm_resource_group.aks_rg.location
  resource_group_name     = azurerm_resource_group.aks_rg.name
  dns_prefix              = "sme-${var.alias}-aks-dns"
  kubernetes_version      = var.kubernetes_version
  
   default_node_pool {
    name                 = "system"
    vm_size              = var.vm_size
    vnet_subnet_id       = azurerm_subnet.sme_aks_subnet.id
    enable_auto_scaling  = "true"
    min_count            = var.min_node_count
    max_count            = var.max_node_count
    node_count           = var.node_count
  }

  identity {
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.aks_uami.id ] 
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.application_gateway.id
  }

  network_profile {
    load_balancer_sku = var.load_balancer_sku
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    dns_service_ip    = var.dns_service_ip
    service_cidr      = var.service_cidr
    outbound_type     = var.outbound_type
  }

  //depends_on = []

}

