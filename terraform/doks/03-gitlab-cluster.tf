module "gitlab_admin_service_account" {
  source               = "../module/gitlab-admin-service-account"
  enabled              = var.enabled
  create_tillerless_ns = var.enabled

  kubernetes_endpoint = local.kubernetes_endpoint
  kubernetes_token    = local.kubernetes_token
  kubernetes_ca_cert  = local.kubernetes_ca_cert
}

data "gitlab_group" "root" {
  count    = length(var.root_gitlab_group) > 0 ? 1 : 0
  group_id = length(var.root_gitlab_group) > 0 ? var.root_gitlab_group : 0
}

resource "gitlab_group_cluster" "root" {
  group = join("", data.gitlab_group.root.*.id)

  name   = local.do_kube_id
  domain = local.domain

  kubernetes_api_url = local.kubernetes_endpoint
  kubernetes_token   = local.kubernetes_token
  kubernetes_ca_cert = base64decode(local.kubernetes_ca_cert)

  ## You can use only one Kubernetes cluster per a group/project when your team uses a free plan on Gitlab.com
  ## If you will set explicitly env scope you can't use Auto DevOps feature
  ##
  ## References:
  ## - https://docs.gitlab.com/12.5/ee/topics/autodevops/index.html#overview
  ## - https://gitlab.com/gitlab-org/gitlab-foss/blob/master/lib/gitlab/ci/templates/Auto-DevOps.gitlab-ci.yml
  environment_scope = "*"
}