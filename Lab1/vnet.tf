
# HUB vnet and subnet
resource "azurerm_virtual_network" "sme_vnet_hub" {
  name                = var.vnet_hub_name 
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.netcore_rg.location
  resource_group_name = azurerm_resource_group.netcore_rg.name
}

resource "azurerm_subnet" "hub_subnet" {
  name                 = "sme_vnet_hub_subnet"
  resource_group_name  = azurerm_resource_group.netcore_rg.name
  virtual_network_name = azurerm_virtual_network.sme_vnet_hub.name 
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "sme_vnet_appgw_subnet"
  resource_group_name  = azurerm_resource_group.netcore_rg.name
  virtual_network_name = azurerm_virtual_network.sme_vnet_hub.name 
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "hub_subnet_nsg" {
  name                = "sme_${var.alias}_hub_subnet_nsg"
  location            = azurerm_resource_group.netcore_rg.location
  resource_group_name = azurerm_resource_group.netcore_rg.name
}

resource "azurerm_subnet_network_security_group_association" "hub_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.hub_subnet.id
  network_security_group_id = azurerm_network_security_group.hub_subnet_nsg.id
}

resource "azurerm_network_security_group" "appgw_subnet_nsg" {
  name                = "sme_${var.alias}_appgw_subnet_nsg"
  location            = azurerm_resource_group.netcore_rg.location
  resource_group_name = azurerm_resource_group.netcore_rg.name

  security_rule {
    name                       = "app_gw_allow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "65200 - 65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "appgw_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.appgw_subnet.id
  network_security_group_id = azurerm_network_security_group.appgw_subnet_nsg.id
}

resource "azurerm_subnet" "fw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.netcore_rg.name
  virtual_network_name = azurerm_virtual_network.sme_vnet_hub.name 
  address_prefixes     = ["10.0.2.0/24"]
}

# AKS vnet and subnet
resource "azurerm_virtual_network" "sme_vnet_aks" {
  name                = var.vnet_aks_name 
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_virtual_network_dns_servers" "sme_vnet_aks_dns_server" {
  virtual_network_id = azurerm_virtual_network.sme_vnet_aks.id
  dns_servers        = [azurerm_network_interface.dns_nic.private_ip_address]
  depends_on         = [azurerm_linux_virtual_machine.dns_vm]
}

resource "azurerm_subnet" "nodes_subnet" {
  name                 = "sme_vnet_aks_subnet_nodes"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.sme_vnet_aks.name 
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_network_security_group" "nodes_subnet_nsg" {
  name                = "sme_${var.alias}_nodes_subnet_nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_subnet_network_security_group_association" "nodes_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.nodes_subnet.id
  network_security_group_id = azurerm_network_security_group.nodes_subnet_nsg.id
} 

resource "azurerm_subnet" "pods_subnet" {
  name                 = "sme_vnet_aks_subnet_pods"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.sme_vnet_aks.name 
  address_prefixes     = ["10.1.1.0/24"]
  delegation {
    name = "Microsoft.ContainerService.managedClusters"
    service_delegation {
      actions = [
      "Microsoft.Network/virtualNetworks/subnets/join/action", ]
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}

resource "azurerm_network_security_group" "pods_subnet_nsg" {
  name                = "sme_${var.alias}_pods_subnet_nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_subnet_network_security_group_association" "pods_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.pods_subnet.id
  network_security_group_id = azurerm_network_security_group.pods_subnet_nsg.id
}

resource "azurerm_virtual_network_peering" "hub_to_aks" {
  name                      = "sme_${var.alias}_hub_to_aks"
  resource_group_name       = azurerm_resource_group.netcore_rg.name
  virtual_network_name      = azurerm_virtual_network.sme_vnet_hub.name
  remote_virtual_network_id = azurerm_virtual_network.sme_vnet_aks.id
}

resource "azurerm_virtual_network_peering" "aks_to_hub" {
  name                      = "sme_${var.alias}_aks_to_hub"
  resource_group_name       = azurerm_resource_group.aks_rg.name
  virtual_network_name      = azurerm_virtual_network.sme_vnet_aks.name
  remote_virtual_network_id = azurerm_virtual_network.sme_vnet_hub.id
}

## Route table
resource "azurerm_route_table" "aks_route_table" {
  name                          = "sme_${var.alias}_aks_routetable"
  location                      = azurerm_resource_group.aks_rg.location
  resource_group_name           = azurerm_resource_group.aks_rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "fw_rule"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }

  route {
    name           = "fw_internet_rule"
    address_prefix = "${azurerm_public_ip.fw_ip.ip_address}/32"
    next_hop_type  = "Internet"
  }

  route {
    name           = "appgw_rule"
    address_prefix = "10.0.1.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }

  depends_on = [azurerm_public_ip.fw_ip]
}

resource "azurerm_subnet_route_table_association" "nodes_rt_association" {
  subnet_id      = azurerm_subnet.nodes_subnet.id
  route_table_id = azurerm_route_table.aks_route_table.id
}

resource "azurerm_subnet_route_table_association" "pods_rt_association" {
  subnet_id      = azurerm_subnet.pods_subnet.id
  route_table_id = azurerm_route_table.aks_route_table.id
}

resource "azurerm_route_table" "appgw_route_table" {
  name                          = "sme_${var.alias}_appgw_routetable"
  location                      = azurerm_resource_group.netcore_rg.location
  resource_group_name           = azurerm_resource_group.netcore_rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "fw_rule"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }

  depends_on = [azurerm_public_ip.fw_ip]
}

resource "azurerm_subnet_route_table_association" "appgw_rt_association" {
  subnet_id      = azurerm_subnet.appgw_subnet.id
  route_table_id = azurerm_route_table.appgw_route_table.id
}

