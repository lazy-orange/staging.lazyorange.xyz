# Enabling IAM Roles for Service Accounts on your Cluster
# 
# https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
# https://medium.com/@marcincuber/amazon-eks-with-oidc-provider-iam-roles-for-kubernetes-services-accounts-59015d15cb0c
#
locals {
  oidc_provider_enabled      = var.oidc_provider_enabled == true ? 1 : 0
  cluster_autoscaler_enabled = var.cluster_autoscaler_enabled == true && local.oidc_provider_enabled == 1 ? 1 : 0

  # IAM Role with specified policy will be mapped to the cluster-autoscaler service account in kube-system namespace
  # Assumed that will be provisioned the service account with cluster-autoscaler name, otherwise it won't work with another service account
  # and you should annotate a service account with needed IAM Role arn 
  #
  # https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html
  # https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html
  service_account_name = var.service_account_name
  kube_ns              = "kube-system"
}

module "cluster_autoscaler" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.4.0"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"
}

resource "aws_iam_role" "cluster_autoscaler" {
  count = local.cluster_autoscaler_enabled
  name  = module.cluster_autoscaler.id

  assume_role_policy = templatefile("${path.module}/assets/oidc_assume_role_policy.json", {
    OIDC_ARN  = var.eks_cluster_identity_oidc_issuer_arn,
    OIDC_URL  = replace(var.eks_cluster_identity_oidc_issuer, "https://", ""),
    NAMESPACE = local.kube_ns,
    SA_NAME   = local.service_account_name
  })

  tags = merge(module.cluster_autoscaler.tags,
    {
      "ServiceAccountName"      = local.service_account_name
      "ServiceAccountNameSpace" = local.kube_ns
    }
  )
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  count = local.cluster_autoscaler_enabled

  name = "CustomPolicy"
  role = element(aws_iam_role.cluster_autoscaler.*.id, 0)

  policy = templatefile("${path.module}/assets/cluster_autoscaler_policy.json", {})

  depends_on = [
    aws_iam_role.cluster_autoscaler
  ]
}