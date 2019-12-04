locals {
  cluster_name = "lazyorange-staging-doks"
  do_kube_id   = digitalocean_kubernetes_cluster.default.id

  kubernetes_endpoint = digitalocean_kubernetes_cluster.default.endpoint
  kubernetes_token    = digitalocean_kubernetes_cluster.default.kube_config[0].token
  kubernetes_ca_cert  = digitalocean_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate

  kubernetes_ca_cert_enc = digitalocean_kubernetes_cluster.default.kube_config[0].cluster_ca_certificate
}

resource "digitalocean_kubernetes_cluster" "default" {
  name   = local.cluster_name
  region = var.region
  // Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.16.2-do.0"

  node_pool {
    name       = "main"
    size       = "s-1vcpu-2gb"
    node_count = 2
  }
}

resource "digitalocean_kubernetes_node_pool" "main" {
  count      = 0
  cluster_id = digitalocean_kubernetes_cluster.default.id

  name       = "main"
  size       = "s-1vcpu-2gb"
  node_count = 1
  tags       = ["main"]
}

provider "kubernetes" {
  host                   = local.kubernetes_endpoint
  token                  = local.kubernetes_token
  cluster_ca_certificate = local.kubernetes_ca_cert
}

module "gitlab_admin_service_account" {
  source  = "../module/gitlab-admin-service-account"
  enabled = var.enabled

  kubernetes_endpoint = local.kubernetes_endpoint
  kubernetes_token    = local.kubernetes_token
  kubernetes_ca_cert  = local.kubernetes_ca_cert
}

resource "kubernetes_namespace" "tillerless" {
  metadata {
    name = "tillerless"
  }
}

data "gitlab_group" "root" {
  count    = length(var.root_gitlab_group) > 0 ? 1 : 0
  group_id = length(var.root_gitlab_group) > 0 ? var.root_gitlab_group : 0
}

resource "gitlab_group_cluster" "root" {
  count = 1

  group = join("", data.gitlab_group.root.*.id)

  name   = local.do_kube_id
  domain = "do.staging.lazyorange.xyz"

  kubernetes_api_url = local.kubernetes_endpoint
  kubernetes_token   = local.kubernetes_token
  kubernetes_ca_cert = local.kubernetes_ca_cert

  ## You can use only one Kubernetes cluster per a group/project when your team uses a free plan on Gitlab.com
  ## If you will set explicitly env scope you can't use Auto DevOps feature
  ##
  ## References:
  ## - https://docs.gitlab.com/12.5/ee/topics/autodevops/index.html#overview
  ## - https://gitlab.com/gitlab-org/gitlab-foss/blob/master/lib/gitlab/ci/templates/Auto-DevOps.gitlab-ci.yml
  environment_scope = "*"
}