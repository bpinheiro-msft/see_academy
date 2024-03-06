
# HUB vnet and subnet
resource "azurerm_virtual_network" "vnet_acr_private" {
  name                = "acrprivateaccess" 
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_subnet" "acr_subnet" {
  name                 = "acr"
  resource_group_name  = azurerm_resource_group.acr_rg.name
  virtual_network_name = azurerm_virtual_network.vnet_acr_private.name 
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "pushvm_subnet" {
  name                 = "pushvm"
  resource_group_name  = azurerm_resource_group.acr_rg.name
  virtual_network_name = azurerm_virtual_network.vnet_acr_private.name 
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "acr_subnet_nsg" {
  name                = "acr_nsg"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_subnet_network_security_group_association" "acr_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.acr_subnet.id
  network_security_group_id = azurerm_network_security_group.acr_subnet_nsg.id
}

resource "azurerm_network_security_group" "pushvm_subnet_nsg" {
  name                = "pushvm_nsg"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_subnet_network_security_group_association" "pushvm_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.pushvm_subnet.id
  network_security_group_id = azurerm_network_security_group.pushvm_subnet_nsg.id
}

# Backbone vnet and subnet
resource "azurerm_virtual_network" "vnet_acr_backbone" {
  name                = "acrbackboneaccess" 
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_subnet" "pullvm_subnet" {
  name                 = "pullvm"
  resource_group_name  = azurerm_resource_group.acr_rg.name
  virtual_network_name = azurerm_virtual_network.vnet_acr_backbone.name 
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_network_security_group" "pullvm_subnet_nsg" {
  name                = "pullvm_nsg"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_subnet_network_security_group_association" "pullvm_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.pullvm_subnet.id
  network_security_group_id = azurerm_network_security_group.pullvm_subnet_nsg.id
} 


## ACR public access vnet and subnet
resource "azurerm_virtual_network" "vnet_acr_public_name" {
  name                = "acrpublicaccess"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_subnet" "pullaks_subnet" {
  name                 = "pullaks"
  resource_group_name  = azurerm_resource_group.acr_rg.name
  virtual_network_name = azurerm_virtual_network.vnet_acr_public_name.name 
  address_prefixes     = ["10.2.0.0/24"]
}

resource "azurerm_network_security_group" "pullaks_subnet_nsg" {
  name                = "pullaks_nsg"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_subnet_network_security_group_association" "pullaks_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.pullaks_subnet.id
  network_security_group_id = azurerm_network_security_group.pullaks_subnet_nsg.id
} 
