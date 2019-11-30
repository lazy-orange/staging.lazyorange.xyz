module "cluster_autoscaler_iam_role" {
  source  = "../module/cluster-autoscaler-iam-role"
  enabled = local.project_cluster_autoscaler_enabled == 0 ? false : true

  name      = "cluster-autoscaler"
  namespace = var.namespace
  stage     = var.stage
  tags      = var.tags

  service_account_name                 = local.service_account_name
  eks_cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  eks_cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
}