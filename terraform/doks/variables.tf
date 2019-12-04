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

variable "root_gitlab_group" {
  type = string
}