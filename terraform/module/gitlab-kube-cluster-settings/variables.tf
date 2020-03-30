variable "root_gitlab_project" {
  type        = string
  description = "A project id that acts as a Gitlab Manage repo, will be used to setup a few environment variables to properly setup other CI jobs"
}

variable "cert_manager_ingress_shim_default_issuer_name" {
  type    = string
  default = "letsencrypt-prod"
}