# References:
# - https://www.terraform.io/docs/providers/do/r/kubernetes_cluster.html
# - https://www.terraform.io/docs/providers/do/r/kubernetes_node_pool.html
# - https://www.terraform.io/docs/providers/do/r/kubernetes_node_pool.html#argument-reference
#
resource "digitalocean_kubernetes_cluster" "default" {
  name   = local.cluster_name
  region = var.region
  // Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.16.2-do.0"

  node_pool {
    name       = "main"
    size       = "s-1vcpu-2gb"
    auto_scale = true
    node_count = 1
    min_nodes  = 1
    max_nodes  = 5
  }
}

# Unforchunetly, the terraform provider for DigitalOcean does not provide an opportunity to add labels to nodes during create.
# by default, DigitalOcean adds label `doks.digitalocean.com/node-pool` to node with name of node pool, this label can be 
# used to setup helm chart for Gitlab Runner
resource "digitalocean_kubernetes_node_pool" "gitlab_runner" {
  count      = var.gitlab_runner_installed ? 1 : 0
  cluster_id = digitalocean_kubernetes_cluster.default.id

  name       = "gitlab-runner"
  size       = "s-1vcpu-2gb"
  node_count = var.gitlab_runner_ng.ng.min_size
  min_nodes  = var.gitlab_runner_ng.ng.min_size
  max_nodes  = var.gitlab_runner_ng.ng.max_size
  tags       = []
}
