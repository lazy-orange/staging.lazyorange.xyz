terraform {
  required_version = "~> 0.12.3"

  required_providers {
    # https://www.terraform.io/docs/providers/do/d/kubernetes_versions.html
    digitalocean = "~> 1.11"
    gitlab       = "~> 2.5"
    kubernetes   = "~> 1.10"
  }
}