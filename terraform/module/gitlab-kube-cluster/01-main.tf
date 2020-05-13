locals {
  environment_scope                = var.stage
  group_cluster_enabled            = length(var.root_gitlab_group) > 0 ? 1 : 0
  project_cluster_enabled          = length(var.root_gitlab_project) > 0 ? 1 : 0

  enabled                          = (var.enabled == true && local.group_cluster_enabled == 1 && local.project_cluster_enabled == 0) ? 1 : 0
  group_gitlab_runner_enabled      = (var.group_gitlab_runner_enabled && length(var.root_gitlab_group) > 0) ? 1 : 0
}

locals {
  cluster_name = var.cluster_name
  domain       = var.dns_zone

  kubernetes_endpoint = var.kubernetes_endpoint
  kubernetes_token    = var.kubernetes_token
  kubernetes_ca_cert  = var.kubernetes_ca_cert
}

data "gitlab_group" "root" {
  count    = length(var.root_gitlab_group) > 0 ? 1 : 0
  group_id = length(var.root_gitlab_group) > 0 ? var.root_gitlab_group : 0
}

resource "gitlab_project_variable" "gitlab_runner_token" {
  count = local.project_cluster_enabled

  project           = var.root_gitlab_project
  key               = "GITLAB_RUNNER_TOKEN"
  value             = join("", data.gitlab_group.root.*.runners_token)
  protected         = true
  environment_scope = "*"
}

# https://www.terraform.io/docs/providers/gitlab/r/project_cluster.html
data "kubernetes_secret" "gitlab_admin_token" {
  count = local.enabled

  metadata {
    name      = module.gitlab_admin_service_account.sa_name
    namespace = "kube-system"
  }
}

# In the next steps we will add a few env variables to Gitlab CI variables 
# to make possible run CI jobs that depends on these variables 
resource "gitlab_project_cluster" "root" {
  count = (var.enabled == true && local.project_cluster_enabled == 1) ? 1 : 0

  project = var.root_gitlab_project

  name   = local.cluster_name
  domain = local.domain

  kubernetes_api_url = local.kubernetes_endpoint
  // kubernetes_token   = data.kubernetes_secret.gitlab_admin_token.data.token
  kubernetes_token   = join("", data.kubernetes_secret.gitlab_admin_token.*.data.token)
  kubernetes_ca_cert = base64decode(local.kubernetes_ca_cert)

  environment_scope = local.environment_scope

  lifecycle {
    ignore_changes = [ kubernetes_ca_cert ]
  }
}

resource "gitlab_group_cluster" "root" {
  count = (var.enabled == true && local.group_cluster_enabled == 1) ? 1 : 0
  group = var.root_gitlab_group

  name   = local.cluster_name
  domain = local.domain

  kubernetes_token   = join("", data.kubernetes_secret.gitlab_admin_token.*.data.token)
  kubernetes_api_url = local.kubernetes_endpoint
  kubernetes_ca_cert = base64decode(local.kubernetes_ca_cert)

  ## You can use only one Kubernetes cluster per a group/project when your team uses a free plan on Gitlab.com
  ## If you will set explicitly env scope you can't use Auto DevOps feature
  ##
  ## References:
  ## - https://docs.gitlab.com/12.5/ee/topics/autodevops/index.html#overview
  ## - https://gitlab.com/gitlab-org/gitlab-foss/blob/master/lib/gitlab/ci/templates/Auto-DevOps.gitlab-ci.yml
  environment_scope = local.environment_scope

  lifecycle {
    ignore_changes = [ kubernetes_ca_cert ]
  }
}
