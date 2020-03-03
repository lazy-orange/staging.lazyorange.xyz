variable "enabled" {
  type    = bool
  default = true
}

variable "cluster_name" {
  type = string
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev' or 'testing'"
}

variable "dns_zone" {
  type        = string
  description = "specifies the DNS suffix for the externally-visible websites and services deployed in the cluster"
}

variable "group_gitlab_runner_enabled" {
  type        = bool
  description = "Setup a gitlab group runner (will be used a group runner token to set GITLAB_RUNNER_TOKEN env variable)"
  default     = true
}

variable "root_gitlab_group" {
  type = string
}

variable "root_gitlab_project" {
  type        = string
  description = "A project id that acts as a Gitlab Manage repo, will be used to setup a few environment variables to properly setup other CI jobs"
}

variable "gitlab_runner_installed" {
  type    = bool
  default = false
}

variable "kubernetes_version" {
  type    = string
  default = "1.15.9-do.0"
}