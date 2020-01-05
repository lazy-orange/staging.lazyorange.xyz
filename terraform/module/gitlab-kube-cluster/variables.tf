variable "enabled" {
  type    = bool
  default = true
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev' or 'testing'"
}

variable "dns_zone" {
  type        = string
  description = "specifies the DNS suffix for the externally-visible websites and services deployed in the cluster"
}

variable "cluster_name" {
  type = string
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

variable "kubernetes_endpoint" {
  type = string
}

variable "kubernetes_token" {
  type = string
}

variable "kubernetes_ca_cert" {
  type = string
}