
resource "azurerm_virtual_network" "vnet" {
  name                = "sme_acr2_vnet" 
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "vm"
  resource_group_name  = azurerm_resource_group.acr_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name 
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "vm_subnet_nsg" {
  name                = "vm_nsg"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
}

resource "azurerm_subnet_network_security_group_association" "vm_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.vm_subnet.id
  network_security_group_id = azurerm_network_security_group.vm_subnet_nsg.id
}
