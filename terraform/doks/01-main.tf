locals {
  cluster_name = var.cluster_name
  domain       = var.dns_zone
  do_kube_id   = digitalocean_kubernetes_cluster.default.id

  kubernetes_endpoint = digitalocean_kubernetes_cluster.default.endpoint
  kubernetes_token    = digitalocean_kubernetes_cluster.default.kube_config[0].token
  kubernetes_ca_cert  = digitalocean_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate
}