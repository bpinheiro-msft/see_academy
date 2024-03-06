
# Create public IPs
resource "azurerm_public_ip" "pullvm_pip" {
  name                = "pullvm_pip"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "pullvm_nsg" {
  name                = "pullvm_nsg"
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
resource "azurerm_network_interface" "pullvm_nic" {
  name                = "pullvm_nic"
  location            = azurerm_resource_group.acr_rg.location
  resource_group_name = azurerm_resource_group.acr_rg.name

  ip_configuration {
    name                          = "pullvm_nic_configuration"
    subnet_id                     = azurerm_subnet.pullvm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pullvm_pip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "pullvm_nic_nsg" {
  network_interface_id      = azurerm_network_interface.pullvm_nic.id
  network_security_group_id = azurerm_network_security_group.pullvm_nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "pullvm" {
  name                  = "pullvm"
  location              = azurerm_resource_group.acr_rg.location
  resource_group_name   = azurerm_resource_group.acr_rg.name
  network_interface_ids = [azurerm_network_interface.pullvm_nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = "pullvm_os_disk"
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
  admin_password = var.vm_pull_admin_password
  disable_password_authentication = "false"
}
