module "gitlab_doks_cluster" {
  source  = "../module/gitlab-kube-cluster"
  stage   = "development"
  enabled = var.enabled

  cluster_name = local.cluster_name
  dns_zone = local.domain

  root_gitlab_project = var.root_gitlab_project
  root_gitlab_group   = var.root_gitlab_group

  kubernetes_endpoint = local.kubernetes_endpoint
  kubernetes_token    = local.kubernetes_token
  kubernetes_ca_cert  = local.kubernetes_ca_cert
}