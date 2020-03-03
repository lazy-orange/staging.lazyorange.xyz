# https://www.terraform.io/docs/providers/do/index.html
# https://www.terraform.io/docs/providers/do/d/kubernetes_cluster.html

module "gitlab_doks_cluster" {
  source             = "../module/gitlab-doks-cluster"
  enabled            = var.enabled
  kubernetes_version = local.kubernetes_version
  stage              = "development"

  group_gitlab_runner_enabled = var.enabled

  // avoid the error (Unable to find cluster with name)
  cluster_name = length(digitalocean_kubernetes_cluster.default.id) > 0 ? local.cluster_name : local.cluster_name
  dns_zone     = local.domain

  root_gitlab_project = var.root_gitlab_project
  root_gitlab_group   = var.root_gitlab_group
}