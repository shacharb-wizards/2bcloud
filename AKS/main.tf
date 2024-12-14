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
  #  kubernetes_version  = "1.29.8"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_type
    #os_disk_size_gb             = 50
    os_sku                      = "AzureLinux"
    temporary_name_for_rotation = "tmpnodepool1"
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  role_based_access_control_enabled = true

}

data "azurerm_kubernetes_cluster" "credentials" {
  name                = azurerm_kubernetes_cluster.k8s.name
  resource_group_name = var.resource_group_name
}

provider "helm" {
  kubernetes {
    #host                   = data.azurerm_kubernetes_cluster.credentials.kube_config.0.host
    #client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_certificate)
    #client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_key)
    #cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.cluster_ca_certificate)
    config_path = "~/.kube/config"

  }
}

# Deploy redis-sentinel
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm fetch bitnami/redis --untar

resource "helm_release" "redis-sentinel" {
  name             = "redis-sentinel"
  chart            = "./redis"
  namespace        = "redis-sentinel"
  create_namespace = true
}

# create ACR
resource "azurerm_container_registry" "acr" {
  name                = "${var.resource_name_prefix}acr"
  resource_group_name = var.resource_group_name
  location            = var.resources_location
  sku                 = "Premium"
  admin_enabled       = true
}