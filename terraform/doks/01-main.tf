locals {
  cluster_name = var.cluster_name
  domain       = var.dns_zone
  # helm chart which is used by default in Auto DevOps pipelines does not support Kubernetes 1.16+ yet
  # Grab the latest version slug from `doctl kubernetes options versions`
  kubernetes_version = "1.15.5-do.2"

  kubernetes_endpoint = digitalocean_kubernetes_cluster.default.endpoint
  kubernetes_token    = digitalocean_kubernetes_cluster.default.kube_config[0].token
  kubernetes_ca_cert  = digitalocean_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate
}