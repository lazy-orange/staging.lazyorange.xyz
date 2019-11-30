locals {
  vpc_cidr_block             = module.vpc.vpc_cidr_block
  eks_worker_ami_name_filter = "amazon-eks-node-${var.kubernetes_version}*"
}

module "eks_main_workers" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-eks-workers.git?ref=tags/0.11.0"
  enabled                            = true
  eks_worker_ami_name_filter         = local.eks_worker_ami_name_filter
  namespace                          = var.namespace
  stage                              = var.stage
  name                               = "${var.name}-main"
  attributes                         = var.attributes
  tags                               = merge(var.tags, { "kubernetes.io/role" = "master" })
  instance_type                      = var.instance_type
  vpc_id                             = module.vpc.vpc_id
  subnet_ids                         = module.subnets.public_subnet_ids
  associate_public_ip_address        = var.associate_public_ip_address
  health_check_type                  = var.health_check_type
  min_size                           = var.min_size
  max_size                           = var.max_size
  wait_for_capacity_timeout          = var.wait_for_capacity_timeout
  cluster_name                       = module.label.id
  cluster_endpoint                   = module.eks_cluster.eks_cluster_endpoint
  cluster_certificate_authority_data = module.eks_cluster.eks_cluster_certificate_authority_data
  cluster_security_group_id          = module.eks_cluster.security_group_id

  allowed_cidr_blocks = [local.vpc_cidr_block]

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = var.autoscaling_policies_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent

  workers_role_policy_arns       = []
  workers_role_policy_arns_count = 0

  bootstrap_extra_args = format("--node-labels=%s", "kubernetes.io/role=master")
}

locals {
  lifecycle = var.gitlab_worker_opts.lifecycle == "Ec2Spot" ? "Ec2Spot" : "OnDemand"

  ng_tags = merge(var.tags, {
    purpose   = "gitlab-runner",
    lifecycle = local.lifecycle,
  })

  keys   = keys(local.ng_tags)
  values = values(local.ng_tags)
}

data "null_data_source" "node_labels" {
  count = "${length(local.keys)}"

  inputs = {
    encoded = format("%s=%s", element(local.keys, count.index), element(local.values, count.index))
  }
}

locals {
  autoscaler_tags = {
    "k8s.io/cluster-autoscaler/enabled"                     = "true",
    format("k8s.io/cluster-autoscaler/%s", module.label.id) = "owned"
  }

  # https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-can-i-scale-a-node-group-to-0
  node_templates_tags = {
    for key, value in local.ng_tags :
    format("k8s.io/cluster-autoscaler/node-template/label/%s", key) => value
  }

  asg_tags = merge(local.ng_tags, local.node_templates_tags, local.autoscaler_tags)

  node_labels = join(",", data.null_data_source.node_labels.*.outputs.encoded)
}

module "eks_workers_gitlab_runnner" {
  source                             = "git::https://github.com/cloudposse/terraform-aws-eks-workers.git?ref=tags/0.11.0"
  enabled                            = true
  namespace                          = var.namespace
  stage                              = var.stage
  name                               = "${var.name}-gitlab-runner"
  eks_worker_ami_name_filter         = local.eks_worker_ami_name_filter
  attributes                         = var.attributes
  tags                               = local.asg_tags
  instance_type                      = var.instance_type
  vpc_id                             = module.vpc.vpc_id
  subnet_ids                         = module.subnets.public_subnet_ids
  associate_public_ip_address        = var.associate_public_ip_address
  health_check_type                  = var.health_check_type
  min_size                           = var.gitlab_worker_opts.ng.min_size
  max_size                           = var.gitlab_worker_opts.ng.max_size
  wait_for_capacity_timeout          = var.wait_for_capacity_timeout
  cluster_name                       = module.label.id
  cluster_endpoint                   = module.eks_cluster.eks_cluster_endpoint
  cluster_certificate_authority_data = module.eks_cluster.eks_cluster_certificate_authority_data
  cluster_security_group_id          = module.eks_cluster.security_group_id

  allowed_cidr_blocks = [local.vpc_cidr_block]

  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = var.autoscaling_policies_enabled
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent

  bootstrap_extra_args = format("--node-labels=%s", local.node_labels)

  // instance_market_options = {
  //   spot_options = {
  //     block_duration_minutes         = 60
  //     max_price                      = "0.12"
  //     spot_instance_type             = "persistent"
  //     instance_interruption_behavior = "terminate"
  //     valid_until                    = null
  //   }
  //   market_type = "spot"
  // }
}