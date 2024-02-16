
## VNET
resource "azurerm_virtual_network" "sme_vnet" {
  name                = var.vnet_name 
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

## AKS Subnet
resource "azurerm_subnet" "sme_aks_subnet" {
  name                 = "sme_${var.alias}_aks_subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.sme_vnet.name 
  address_prefixes     = ["10.0.0.0/24"]

}

resource "azurerm_network_security_group" "sme_aks_subnet_nsg" {
  name                = "sme_${var.alias}_aks_nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_aks_nsg_association" {
  subnet_id                 = azurerm_subnet.sme_aks_subnet.id
  network_security_group_id = azurerm_network_security_group.sme_aks_subnet_nsg.id
}

## APP GW Subnet
resource "azurerm_subnet" "sme_appgw_subnet" {
  name                 = "sme_${var.alias}_appgw_subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.sme_vnet.name 
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "sme_appgw_subnet_nsg" {
  name                = "sme_${var.alias}_appgw_nsg"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

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

resource "azurerm_subnet_network_security_group_association" "sme_appgw_nsg_association" {
  subnet_id                 = azurerm_subnet.sme_appgw_subnet.id
  network_security_group_id = azurerm_network_security_group.sme_appgw_subnet_nsg.id
}