module "gitlab_doks_cluster" {
  source = "../module/gitlab-kube-cluster"
  stage  = "development"

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
  protected         = true
  environment_scope = "*"

  depends_on = [module.gitlab_doks_cluster]
}
