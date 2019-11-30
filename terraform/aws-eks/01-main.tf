module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = compact(concat(var.attributes, list("cluster")))
  tags       = var.tags
}

locals {
  # The usage of the specific kubernetes.io/cluster/* resource tags below are required
  # for EKS and Kubernetes to discover and manage networking resources
  # https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#base-vpc-networking
  # // map("kubernetes.io/cluster/${module.label.id}", "shared")
  tags = merge(module.label.tags, map("kubernetes.io/cluster/${module.label.id}", "shared"))

  vpc_eks_cidr_block = "172.16.0.0/16"
}

module "vpc" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=tags/0.8.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = var.attributes
  cidr_block = local.vpc_eks_cidr_block
  tags       = local.tags
}

module "subnets" {
  source               = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=tags/0.16.0"
  availability_zones   = var.availability_zones
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  attributes           = var.attributes
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = false
  nat_instance_enabled = false
  tags                 = local.tags
}

module "eks_cluster" {
  source                 = "git::https://github.com/cloudposse/terraform-aws-eks-cluster.git?ref=0.13.0"
  enabled                = true
  namespace              = var.namespace
  stage                  = var.stage
  name                   = var.name
  attributes             = var.attributes
  tags                   = var.tags
  region                 = var.region
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.subnets.public_subnet_ids
  kubernetes_version     = var.kubernetes_version
  kubeconfig_path        = var.kubeconfig_path
  local_exec_interpreter = var.local_exec_interpreter

  oidc_provider_enabled = true

  workers_role_arns = [
    module.eks_main_workers.workers_role_arn,
    module.eks_workers_gitlab_runnner.workers_role_arn,
  ]

  workers_security_group_ids = [
    module.eks_main_workers.security_group_id,
    module.eks_workers_gitlab_runnner.security_group_id,
  ]
}