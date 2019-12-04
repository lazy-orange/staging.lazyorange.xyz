provider "kubernetes" {
  host                   = var.kubernetes_endpoint
  token                  = var.kubernetes_token
  cluster_ca_certificate = base64decode(var.kubernetes_ca_cert)
}