variable "region" {
  type        = string
  description = "DigitalOcean Region"
}

variable "enabled" {
  type    = bool
  default = true
}

variable "cluster_name" {
  type = string
}

variable "dns_zone" {
  type        = string
  description = "specifies the DNS suffix for the externally-visible websites and services deployed in the cluster"
}

variable "root_gitlab_group_id" {
  type = string
}

variable "gitlab_runner_installed" {
  type    = bool
  default = false
}

variable "gitlab_runner_ng" {
  type = object({
    ng = object({
      min_size = number,
      max_size = number,
    })
  })

  default = {
    ng = {
      min_size = 1,
      max_size = 2
    }
  }
}