###  part 2

# # Create candidate resource group 
# resource "azurerm_resource_group" "rg" {
#   location = var.resources_location
#   name     = var.resource_group_name
# }

# # Use candidate resource group
# data "azurerm_resource_group" "rg" {
#   name = var.resource_group_name
# }

# # Use user assigned identity to be used with resources
# data "azurerm_user_assigned_identity" "user_assigned_identity" {
#   name                = data.
# }

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = var.resources_location
  name                = "${var.resource_name_prefix}-aks"
  resource_group_name = var.resource_group_name
  dns_prefix          = var.resource_name_prefix
  sku_tier            = "Standard"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_type
    #os_disk_size_gb             = 50
    os_sku                      = "AzureLinux"
    temporary_name_for_rotation = "tmpnodepool1"
  }

  # change from SP to MSI
  # service_principal {
  #   client_id     = var.appId
  #   client_secret = var.password
  # }
  
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_assigned_identity.id]
  }

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  # # enable addons not working
  # addon_profile {
  #   http_application_routing {
  #     enabled = true
  #   }
  #   azure_keyvault_secrets_provider {
  #     enabled = true
  #   }
  # }
  # web_app_routing {
  #     dns_zone_ids = azurerm_dns_zone.zone.name_servers
  # }
  


  #http_application_routing_enabled = true
  
  key_vault_secrets_provider {
    secret_rotation_enabled = true
    secret_rotation_interval = "30h"
  }

  role_based_access_control_enabled = true

}

data "azurerm_kubernetes_cluster" "credentials" {
  name                = azurerm_kubernetes_cluster.k8s.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_kubernetes_cluster.k8s]
}

provider "helm" {
  kubernetes {
    # host                   = data.azurerm_kubernetes_cluster.credentials.kube_config.0.host
    # client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_certificate)
    # client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_key)
    # cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.cluster_ca_certificate)
    #in case Error: Kubernetes cluster unreachable
    config_path = "~/.kube/config"

  }
}

# create ACR
resource "azurerm_container_registry" "acr" {
  name                = "${var.resource_name_prefix}acr"
  resource_group_name = var.resource_group_name
  location            = var.resources_location
  sku                 = "Premium"
  admin_enabled       = true
}

# add the role to the identity the kubernetes cluster was assigned
resource "azurerm_role_assignment" "k8s_to_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  
}
