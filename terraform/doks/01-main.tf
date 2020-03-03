locals {
  cluster_name = var.cluster_name
  domain       = var.dns_zone
  # helm chart which is used by default in Auto DevOps pipelines does not support Kubernetes 1.16+ yet
  # Grab the latest version slug from `doctl kubernetes options versions`
  kubernetes_version = var.kubernetes_version
}