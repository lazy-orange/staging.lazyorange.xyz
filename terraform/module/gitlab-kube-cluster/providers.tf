provider "kubernetes" {
  version                = "1.10.0"
  load_config_file         = false

  host                   = var.kubernetes_endpoint
  token                  = var.kubernetes_token
  cluster_ca_certificate = base64decode(var.kubernetes_ca_cert)
}