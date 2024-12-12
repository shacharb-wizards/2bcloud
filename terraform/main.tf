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
  resource_group_name = var.resource_group_name
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

# Create NIC

# Connect the NSG to NIC

# Create virtual machine


## Deploy Jenkins in VM ##