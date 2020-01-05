resource "kubernetes_service_account" "gitlab_admin_service_account" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "gitlab-admin"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "gitlab_admin_cluster_role_binding" {
  count = var.enabled ? 1 : 0

  metadata {
    name = "gitlab-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "gitlab-admin"
    namespace = "kube-system"
  }
}

resource "kubernetes_namespace" "tillerless" {
  count = var.create_tillerless_ns && var.enabled ? 1 : 0

  metadata {
    name = "tillerless"
  }
}