terraform {
  required_version = "~> 0.12.0"

  # References:
  # - https://www.terraform.io/docs/providers/kubernetes/index.html

  required_providers {
    aws        = "~> 2.35"
    gitlab     = "~> 2.4"
    kubernetes = "~> 1.10"
  }
}