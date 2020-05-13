module "gitlab_admin_service_account" {
  // source               = "../gitlab-admin-service-account"
  source = "git::https://gitlab.com/lazyorangejs/staging.lazyorange.xyz//terraform/module/gitlab-admin-service-account?ref=tags/v0.5.1"
  enabled              = var.enabled

  // FIXME: remove this shirt from this module
  create_tillerless_ns = false

  kubernetes_endpoint = local.kubernetes_endpoint
  kubernetes_token    = local.kubernetes_token
  kubernetes_ca_cert  = local.kubernetes_ca_cert
}
