variable "enabled" {
  type    = bool
  default = true
}

variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev' or 'testing'"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "service_account_name" {
  type = string
}

variable "oidc_provider_enabled" {
  type    = bool
  default = true
}

variable "cluster_autoscaler_enabled" {
  type    = bool
  default = true
}

variable "eks_cluster_identity_oidc_issuer" {
  type = string
}

variable "eks_cluster_identity_oidc_issuer_arn" {
  type = string
}