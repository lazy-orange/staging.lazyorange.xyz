# In this case was used the terraform-aws-tfstate-backend module by CloudPosse to create a AWS S3 backend.
# You can can create an s3 backend in other way.
#
# References:
# - https://github.com/cloudposse/terraform-aws-tfstate-backend
# - https://github.com/cloudposse/terraform-aws-tfstate-backend#usage
# - https://github.com/cloudposse/terraform-aws-tfstate-backend/releases
# ```bash
# $ cd ./terraform/doks
# $ cp remote-state.tf.example remote-state.tf
# $ terraform init
# $ terraform apply -var-file fra1.tfvars -target=module.terraform_state_backend
# $ terraform output terraform_backend_config >> remote-state.tf
# $ terraform init
#```

// module "terraform_state_backend" {
//   source        = "git::https://github.com/cloudposse/terraform-aws-tfstate-backend.git?ref=0.9.0"
//   namespace     = "lo"
//   stage         = "dev"
//   region        = "eu-central-1"
//   name          = "terraform"
//   attributes    = ["state", "digital-ocean", "gitlab"]
//   force_destroy = true
// }

// output "terraform_backend_config" {
//   value = module.terraform_state_backend.terraform_backend_config
// }

terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "eu-central-1"
    bucket         = "lo-dev-terraform-state-digital-ocean-gitlab"
    key            = "terraform.tfstate"
    dynamodb_table = "lo-dev-terraform-state-digital-ocean-gitlab-lock"
    profile        = ""
    role_arn       = ""
    encrypt        = "true"
  }
}