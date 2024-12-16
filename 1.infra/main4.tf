###  part 4

# Deploy cert_manager

resource "helm_release" "cert_manager" {
  name = "cert-manager"

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.16.2"
  depends_on       = [azurerm_kubernetes_cluster.k8s]

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# connect AKV to AKS

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.credentials.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.cluster_ca_certificate)
  #in case Error: Kubernetes cluster unreachable
  #config_path = "~/.kube/config"
}

provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.credentials.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.credentials.kube_config.0.cluster_ca_certificate)
  #in case Error: Kubernetes cluster unreachable
  #config_path = "~/.kube/config"
  load_config_file       = false
}

# create namespace
resource "kubernetes_namespace" "csi_namespace" {
  metadata {
    name = "secret-test"
  }
  depends_on = [azurerm_kubernetes_cluster.k8s]
}

# deploy SecretProviderClass
data "kubectl_file_documents" "SecretProviderClass" {
  content = file("../AKV_integration/SecretProviderClass.yaml")
}

resource "kubectl_manifest" "SecretProviderClass" {
  for_each  = data.kubectl_file_documents.SecretProviderClass.manifests
  yaml_body = each.value
  depends_on = [kubernetes_namespace.csi_namespace]
}

# deploy busybox  to test the mount of passwords
data "kubectl_file_documents" "busybox" {
  content = file("../AKV_integration/busybox.yaml")
}

resource "kubectl_manifest" "busybox" {
  for_each  = data.kubectl_file_documents.busybox.manifests
  yaml_body = each.value
  depends_on = [kubectl_manifest.SecretProviderClass]
}