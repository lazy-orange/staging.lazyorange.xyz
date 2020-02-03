data "aws_eks_cluster" "default" {
  name = module.eks_cluster.eks_cluster_id
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks_cluster.eks_cluster_id
}

module "gitlab_eks_cluster" {
  source = "../module/gitlab-kube-cluster"
  stage  = "development"

  enabled                     = var.enabled
  group_gitlab_runner_enabled = var.enabled

  cluster_name = module.eks_cluster.eks_cluster_id
  dns_zone     = var.dns_zone

  root_gitlab_project = var.root_gitlab_project
  root_gitlab_group   = var.root_gitlab_group

  kubernetes_endpoint = data.aws_eks_cluster.default.endpoint
  kubernetes_token    = data.aws_eks_cluster_auth.default.token
  kubernetes_ca_cert  = data.aws_eks_cluster.default.certificate_authority.0.data
}

locals {
  project_cluster_autoscaler_enabled = 1
  service_account_name               = "cluster-autoscaler"
}

data "gitlab_project" "root" {
  count = local.project_cluster_autoscaler_enabled
  id    = length(var.root_gitlab_project) > 0 ? var.root_gitlab_project : 0
}

resource "gitlab_project_variable" "cluster_autoscaler_installed" {
  count = local.project_cluster_autoscaler_enabled

  project           = join("", data.gitlab_project.root.*.id)
  key               = "CLUSTER_AUTOSCALER_INSTALLED"
  value             = "true"
  environment_scope = "*"
}

resource "gitlab_project_variable" "cluster_autoscaler" {
  count = local.project_cluster_autoscaler_enabled

  project           = join("", data.gitlab_project.root.*.id)
  key               = "CLUSTER_AUTOSCALER_IAM_ROLE_NAME"
  value             = module.cluster_autoscaler_iam_role.role_arn
  protected         = true
  environment_scope = "*"
}

resource "gitlab_project_variable" "cluster_autoscaler_rbac_sa_name" {
  count = local.project_cluster_autoscaler_enabled

  project           = join("", data.gitlab_project.root.*.id)
  key               = "CLUSTER_AUTOSCALER_RBAC_SERVICE_ACCOUNT_NAME"
  value             = local.service_account_name
  protected         = true
  environment_scope = "*"
}