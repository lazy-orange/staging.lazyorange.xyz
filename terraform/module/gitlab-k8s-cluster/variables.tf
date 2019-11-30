variable "region" {
  type        = string
  description = "AWS Region"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev' or 'testing'"
}

variable "group_gitlab_runner_enabled" {
  type        = bool
  description = "Setup a gitlab group runner (will be used a group runner token to set GITLAB_RUNNER_TOKEN env variable)"
  default     = true
}

variable "root_gitlab_group" {
  type    = string
  default = ""
}

variable "root_gitlab_project" {
  type        = number
  description = "A gitlab project id, a project will be used as a CI to manage Kubernetes clusters"
}

variable "kube_ingress_base_domain" {
  type        = string
  description = "Auto DevOps base domain (https://docs.gitlab.com/12.4/ee/topics/autodevops/index.html#auto-devops-base-domain)"
}

variable "eks_cluster_name" {
  type        = string
  description = "A kubernetes cluster name from EKS console"
}

variable "enabled" {
  type    = bool
  default = true
}