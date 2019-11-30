# https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html#add-existing-eks-cluster
resource "kubernetes_service_account" "eks_admin_service_account" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "eks-admin"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "eks_admin_cluster_role_binding" {
  count = var.enabled ? 1 : 0

  metadata {
    name = "eks-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "eks-admin"
    namespace = "kube-system"
  }
}