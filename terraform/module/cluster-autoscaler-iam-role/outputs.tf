output "role_arn" {
  value = element(aws_iam_role.cluster_autoscaler.*.arn, 0)
}