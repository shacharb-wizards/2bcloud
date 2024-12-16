# Main part 1
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create candidate resource group 
# resource "azurerm_resource_group" "rg" {
#   location = var.resources_location
#   name     = var.resource_group_name
# }

# Use candidate resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# create user assigned identity to be used with resources
resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = "${var.resource_name_prefix}-mi"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Create role assignment
resource "azurerm_role_assignment" "role_assignment" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.user_assigned_identity.principal_id
}

# choose role
data "azurerm_role_definition" "owner" {
  name = "Owner"
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


# get subscription name
data "azurerm_subscription" "sandbox" {}


# Create virtual machine
resource "azurerm_linux_virtual_machine" "jenkins_vm" {
  name                  = "${var.resource_name_prefix}-jenkins"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.jenkins_nic.id]
  size                  = "Standard_DS1_v2"


  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identity.id]
  }

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

## prepapre AKV

data "azurerm_client_config" "current" {}

locals {
  current_user_id = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
}

resource "azurerm_key_vault" "vault" {
  name                       = "${var.resource_name_prefix}-kv"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.kv_sku_name
  soft_delete_retention_days = 7

  enabled_for_deployment    = true
  enable_rbac_authorization = true

  # Use access policy  or RBAC ( I choosed RBAC)
  # access_policy {
  #   tenant_id = data.azurerm_client_config.current.tenant_id
  #   object_id = local.current_user_id

  #   key_permissions         = var.key_permissions
  #   certificate_permissions = var.certificate_permissions
  #   secret_permissions      = var.secret_permissions
  #   storage_permissions     = var.storage_permissions
  # }

}

# Create role assignment for AKV
resource "azurerm_role_assignment" "akv_role_assignment" {
  scope                = azurerm_key_vault.vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_user_assigned_identity.user_assigned_identity.principal_id
}

