
# Create public IPs
resource "azurerm_public_ip" "pushvm_pip" {
  name                = "pushvm_pip"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "pushvm_nsg" {
  name                = "pushvm_nsg"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name

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
resource "azurerm_network_interface" "pushvm_nic" {
  name                = "pushvm_nic"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name

  ip_configuration {
    name                          = "pushvm_nic_configuration"
    subnet_id                     = azurerm_subnet.pushvm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pushvm_pip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "pushvm_nic_nsg" {
  network_interface_id      = azurerm_network_interface.pushvm_nic.id
  network_security_group_id = azurerm_network_security_group.pushvm_nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "pushvm" {
  name                  = "pushvm"
  location              = azurerm_resource_group.acr_rg.location
  resource_group_name   = azurerm_resource_group.acr_rg.name
  network_interface_ids = [azurerm_network_interface.pushvm_nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = "pushvm_os_disk"
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
  admin_password = var.vm_push_admin_password
  disable_password_authentication = "false"
}
