output "sa_name" {
  value = join(",", kubernetes_service_account.gitlab_admin_service_account.*.default_secret_name)
}