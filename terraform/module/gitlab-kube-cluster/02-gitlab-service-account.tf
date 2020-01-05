module "gitlab_admin_service_account" {
  source               = "../gitlab-admin-service-account"
  enabled              = var.enabled
  create_tillerless_ns = var.enabled

  kubernetes_endpoint = local.kubernetes_endpoint
  kubernetes_token    = local.kubernetes_token
  kubernetes_ca_cert  = local.kubernetes_ca_cert
}
