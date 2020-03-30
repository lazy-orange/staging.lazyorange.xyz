data "gitlab_project" "root" {
  id = var.root_gitlab_project
}

resource "gitlab_project_variable" "cert_manager_ingress_shim_default_issuer_name" {
  project           = data.gitlab_project.root.id
  key               = "CERT_MANAGER_INGRESS_SHIM_DEFAULT_ISSUER_NAME"
  value             = var.cert_manager_ingress_shim_default_issuer_name
  protected         = false
  environment_scope = "*"
}