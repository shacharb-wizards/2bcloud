# Main
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# # Create candidate resource group 
# resource "azurerm_resource_group" "rg" {
#   location = var.resources_location
#   name     = var.resource_group_name
# }

# Use candidate resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = var.resources_location
  name                = "${var.resource_name_prefix}-aks"
  resource_group_name = var.resource_group_name
  dns_prefix          = var.resource_name_prefix
  sku_tier            = "Standard"

  # using 
  # identity {
  #   type = "SystemAssigned"
  # }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = var.node_type
    node_count = var.node_count
    os_sku     = "AzureLinux"
  }
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }
  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
  }
}