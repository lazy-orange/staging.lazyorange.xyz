variable "enabled" {
  type    = bool
  default = true
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