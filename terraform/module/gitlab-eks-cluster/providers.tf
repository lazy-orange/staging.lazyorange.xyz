provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "default" {
  name = var.eks_cluster_name
}

# https://www.terraform.io/docs/providers/aws/d/eks_cluster_auth.html
data "aws_eks_cluster_auth" "default" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = "${data.aws_eks_cluster.default.endpoint}"
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.default.certificate_authority.0.data)}"
  token                  = "${data.aws_eks_cluster_auth.default.token}"
  load_config_file       = false
}