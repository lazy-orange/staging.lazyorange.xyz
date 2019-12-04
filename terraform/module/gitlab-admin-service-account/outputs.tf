output "sa_name" {
    value = kubernetes_service_account.gitlab_admin_service_account.0.default_secret_name
}