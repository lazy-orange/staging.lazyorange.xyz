variable "region" {
  type        = string
  description = "DigitalOcean Region"
}

variable "enabled" {
  type    = bool
  default = true
}

variable "root_gitlab_group" {
  type = string
}