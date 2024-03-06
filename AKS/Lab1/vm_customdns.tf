
# Create public IPs
resource "azurerm_public_ip" "dns_public_ip" {
  name                = "sme_${var.alias}_dns_public_ip"
  location            = azurerm_resource_group.netcore_rg.location
  resource_group_name = azurerm_resource_group.netcore_rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "dns_nsg" {
  name                = "sme_${var.alias}_dns_nsg"
  location            = azurerm_resource_group.netcore_rg.location
  resource_group_name = azurerm_resource_group.netcore_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "dns_nic" {
  name                = "sme_${var.alias}_nic"
  location            = azurerm_resource_group.netcore_rg.location
  resource_group_name = azurerm_resource_group.netcore_rg.name

  ip_configuration {
    name                          = "sme_${var.alias}_nic_configuration"
    subnet_id                     = azurerm_subnet.hub_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dns_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "dns_nic_nsg" {
  network_interface_id      = azurerm_network_interface.dns_nic.id
  network_security_group_id = azurerm_network_security_group.dns_nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "dns_vm" {
  name                  = "sme_${var.alias}_dns"
  location              = azurerm_resource_group.netcore_rg.location
  resource_group_name   = azurerm_resource_group.netcore_rg.name
  network_interface_ids = [azurerm_network_interface.dns_nic.id]
  size                  = "Standard_D2s_v3"

  os_disk {
    name                 = "sme_${var.alias}_dns_os_disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "hostname"
  admin_username = var.vm_admin_username
  admin_password = var.vm_dns_admin_password
  disable_password_authentication = "false"  

  custom_data = filebase64("dnsserver.sh")
}
