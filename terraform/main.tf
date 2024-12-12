# Main
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create candidate resource group 
resource "azurerm_resource_group" "rg" {
  location = var.resources_location
  name     = var.resource_group_name
}

## create Jenkins VM ##

# Create virtual network
resource "azurerm_virtual_network" "vm_network" {
  name                = "${var.resource_name_prefix}-vm-vnet"
  address_space       = ["10.3.0.0/16"]
  location            = var.resources_location
  resource_group_name = var.resource_group_name
}

# Create subnet
resource "azurerm_subnet" "vm_subnet" {
  name                 = "${var.resource_name_prefix}-vm-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vm_network.name
  address_prefixes     = ["10.3.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "jenkins_public_ip" {
  name                = "${var.resource_name_prefix}-pubip-jenkins"
  location            = var.resources_location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"
  allocation_method   = "Dynamic"
}

# Create NSG and rule
resource "azurerm_network_security_group" "jenkins_nsg" {
  name                = "${var.resource_name_prefix}-nsg-jenkins"
  location            = var.resources_location
  resource_group_name = var.resource_group_name

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
  security_rule {
    name                       = "Jenkins-8080"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Create NIC
resource "azurerm_network_interface" "jenkins_nic" {
  name                = "${var.resource_name_prefix}-nic-jenkins"
  location            = var.resources_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.resource_name_prefix}-ip-jenkins"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins_public_ip.id
  }
}

# Connect the NSG to NIC
resource "azurerm_network_interface_security_group_association" "nsg_to_nic" {
  network_interface_id      = azurerm_network_interface.jenkins_nic.id
  network_security_group_id = azurerm_network_security_group.jenkins_nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "jenkins_vm" {
  name                  = "${var.resource_name_prefix}-jenkins"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.jenkins_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "50"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "jenkins"
  admin_username = var.username
  custom_data    = base64encode(data.template_file.linux-vm-cloud-init.rendered)

  admin_ssh_key {
    username   = var.username
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }

}

## Deploy Jenkins in VM ##
# Data template Bash bootstrapping file
data "template_file" "linux-vm-cloud-init" {
  template = file("azure-custom-data.sh")
}