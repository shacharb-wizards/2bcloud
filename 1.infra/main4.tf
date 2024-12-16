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