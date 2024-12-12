# Main
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create candidate resource group 
resource "azurerm_resource_group" "rg" {
  location = var.resources_location
  name     = "${var.resource_name_prefix}_rg"
}

## create Jenkins VM ##

# Create virtual network

# Create subnet

# Create public IPs

# Create NSG and rule

# Create NIC

# Connect the NSG to NIC

# Create virtual machine


## Deploy Jenkins in VM ##