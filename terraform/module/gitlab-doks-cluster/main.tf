locals {
  cluster_name = var.cluster_name
  domain       = var.dns_zone
  # helm chart which is used by default in Auto DevOps pipelines does not support Kubernetes 1.16+ yet
  # Grab the latest version slug from `doctl kubernetes options versions`
  kubernetes_version = var.kubernetes_version

  kubernetes_endpoint = data.digitalocean_kubernetes_cluster.default.endpoint
  kubernetes_token    = data.digitalocean_kubernetes_cluster.default.kube_config[0].token
  kubernetes_ca_cert  = data.digitalocean_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate
}

data "digitalocean_kubernetes_cluster" "default" {
  name = var.cluster_name
}

module "gitlab_doks_cluster" {
  source = "../gitlab-kube-cluster"
  stage  = var.stage

  enabled                     = var.enabled
  group_gitlab_runner_enabled = var.enabled

  cluster_name = local.cluster_name
  dns_zone     = local.domain

  root_gitlab_project = var.root_gitlab_project
  root_gitlab_group   = var.root_gitlab_group

  kubernetes_endpoint = local.kubernetes_endpoint
  kubernetes_token    = local.kubernetes_token
  kubernetes_ca_cert  = local.kubernetes_ca_cert
}

data "gitlab_project" "root" {
  id = var.root_gitlab_project
}

resource "gitlab_project_variable" "cluster_name" {
  project           = data.gitlab_project.root.id
  key               = "KUBE_CLUSTER_NAME"
  value             = local.cluster_name
  protected         = false
  environment_scope = "*"

  depends_on = [module.gitlab_doks_cluster]
}

resource "gitlab_project_variable" "kube_ingress_base_domain" {
  project           = data.gitlab_project.root.id
  key               = "KUBE_INGRESS_BASE_DOMAIN"
  value             = local.cluster_name
  protected         = false
  environment_scope = "*"

  depends_on = [module.gitlab_doks_cluster]
}
