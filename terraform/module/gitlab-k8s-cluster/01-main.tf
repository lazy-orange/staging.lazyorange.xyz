// data "gitlab_group" "root" {
//   full_path = var.root_gitlab_group
// }

// locals {
//   root_id = data.gitlab_group.root.id
// }

# create a group that contains git repos related to backend/frontend side
// resource "gitlab_group" "nestjs_cloud" {
//   parent_id = local.root_id

//   name        = "Nest.js Cloud"
//   description = "A list of services built with Nest.js"
//   path        = "nestjscloud"
// }

// resource "gitlab_group_variable" "nestjs_cloud" {
//   for_each = {
//     AWS_DEFAULT_REGION           = "eu-central-1"
//     HELM_VERSION                 = "v2.15.1"
//     HELMFILE_VERSION             = "v0.89.0"
//     STAGING_ENABLED              = "yes"
//     CODE_QUALITY_DISABLED        = "yes"
//     LICENSE_MANAGEMENT_DISABLED  = "yes"
//     PERFORMANCE_DISABLED         = "yes"
//     SAST_DISABLED                = "yes"
//     DEPENDENCY_SCANNING_DISABLED = "yes"
//     CONTAINER_SCANNING_DISABLED  = "yes"
//     DAST_DISABLED                = "yes"
//   }
//   group = gitlab_group.nestjs_cloud.id
//   key   = each.key
//   value = each.value
// }

// resource "gitlab_group" "ops" {
//   parent_id = local.root_id

//   name        = "Ops"
//   description = "A list of gitlab templates, helm charts/templates, etc"
//   path        = "ops"
// }

// resource "gitlab_project" "gitlab_templates" {
//   namespace_id = gitlab_group.ops.id

//   default_branch = "master"

//   name = "gitlab-templates"
//   path = "gitlab-templates"
// }

// resource "gitlab_project" "nodejs_auto_deploy_app" {
//   namespace_id = gitlab_group.ops.id

//   name        = "nodejs-auto-deploy-app"
//   description = "A Helm Chart that fits to Node.js backend and MongoDB as a primary database (https://gitlab.com/gitlab-org/charts/auto-deploy-app)"
// }

// resource "gitlab_project" "cloudnativenestjs" {
//   namespace_id = gitlab_group.nestjs_cloud.id

//   default_branch = "master"

//   name = "CloudNative Nest.js application"
//   path = "cloudnativenestjs"
// }

locals {
  environment_scope                = var.stage
  group_cluster_autoscaler_enabled = length(var.root_gitlab_group) > 0 ? 1 : 0
  group_gitlab_runner_enabled      = (var.group_gitlab_runner_enabled && length(var.root_gitlab_group) > 0) ? 1 : 0
}

# In the next steps we will add a few env variables to Gitlab CI variables 
# to make possible run CI jobs that depends on these variables 
data "gitlab_project" "root" {
  id = var.root_gitlab_project
}

data "gitlab_group" "root" {
  count    = length(var.root_gitlab_group) > 0 ? 1 : 0
  group_id = length(var.root_gitlab_group) > 0 ? var.root_gitlab_group : 0
}

resource "gitlab_project_variable" "eks_cluster_name" {
  project           = data.gitlab_project.root.id
  key               = "EKS_CLUSTER_NAME"
  value             = data.aws_eks_cluster.default.id
  protected         = true
  environment_scope = "*"
}

resource "gitlab_project_variable" "gitlab_runner_token" {
  count = local.group_gitlab_runner_enabled

  project           = data.gitlab_project.root.id
  key               = "GITLAB_RUNNER_TOKEN"
  value             = join("", data.gitlab_group.root.*.runners_token)
  protected         = true
  environment_scope = "*"
}

# https://www.terraform.io/docs/providers/gitlab/r/project_cluster.html
data "kubernetes_secret" "gitlab_admin_token" {
  metadata {
    name      = kubernetes_service_account.eks_admin_service_account.0.default_secret_name
    namespace = "kube-system"
  }
}

resource "gitlab_project_cluster" "root" {
  for_each = {
    project_cluster_sandbox = data.gitlab_project.root.id
  }
  project = each.value

  name   = data.aws_eks_cluster.default.id
  domain = var.kube_ingress_base_domain

  kubernetes_api_url = data.aws_eks_cluster.default.endpoint
  kubernetes_token   = data.kubernetes_secret.gitlab_admin_token.data.token
  kubernetes_ca_cert = "${base64decode(data.aws_eks_cluster.default.certificate_authority.0.data)}"

  environment_scope = local.environment_scope
}

resource "gitlab_group_cluster" "root" {
  count = local.group_cluster_autoscaler_enabled

  group = join("", data.gitlab_group.root.*.id)

  name   = data.aws_eks_cluster.default.id
  domain = var.kube_ingress_base_domain

  kubernetes_api_url = data.aws_eks_cluster.default.endpoint
  kubernetes_token   = data.kubernetes_secret.gitlab_admin_token.data.token
  kubernetes_ca_cert = "${base64decode(data.aws_eks_cluster.default.certificate_authority.0.data)}"

  ## You can use only one Kubernetes cluster per a group/project when your team uses a free plan on Gitlab.com
  ## If you will set explicitly env scope you can't use Auto DevOps feature
  ##
  ## References:
  ## - https://docs.gitlab.com/12.5/ee/topics/autodevops/index.html#overview
  ## - https://gitlab.com/gitlab-org/gitlab-foss/blob/master/lib/gitlab/ci/templates/Auto-DevOps.gitlab-ci.yml
  environment_scope = "*"
}