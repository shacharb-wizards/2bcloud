###  part 3

# Deploy redis-sentinel
# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm fetch bitnami/redis --untar

resource "helm_release" "redis-sentinel" {
  name             = "redis-sentinel"
  chart            = "../redis"
  namespace        = "apps"
  create_namespace = true
}


# create DNS zone
resource "azurerm_dns_zone" "zone" {
  name = var.dns_zone_name
  resource_group_name = var.resource_group_name
}

# create static IP for Ingress
resource "azurerm_public_ip" "ingress_public_ip" {
  name                = "ingress_public_ip"
  location            = var.resources_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_public_ip.ingress_public_ip]
}

# Register ingress_public_ip in DNS
resource "azurerm_dns_a_record" "ingress_record" {
  name                = "www"
  resource_group_name = var.resource_group_name
  zone_name           = azurerm_dns_zone.zone.name
  ttl                 = var.dns_ttl
  records             = [azurerm_public_ip.ingress_public_ip.ip_address]
}

# # create ingress nginx controller
# resource "helm_release" "ingress-nginx" {
#   name = "external"
#   repository       = "https://kubernetes.github.io/ingress-nginx"
#   chart            = "ingress-nginx"
#   namespace        = "apps"
#   create_namespace = true
#   version          = "4.11.3"

#   values = [file("${path.module}/ingress.yaml")]
# }
