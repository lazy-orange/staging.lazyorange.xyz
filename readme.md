## Motivation 

Manage the Kubernetes cluster and its dependencies can be hard, then when you is already familiar with main features provided by Gitlab and its integration with [AWS EKS](https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html#eks-cluster) and [Google Kubernetes Engine](https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html#gke-cluster), [Auto DevOps feature](https://docs.gitlab.com/ee/topics/autodevops/#overview), using Gitlab UI you will want to manage its dependices such [NGinx Ingress Controller](https://github.com/helm/charts/tree/master/stable/nginx-ingress), CertManager, Gitlab Runner, etc through [GitOps](https://www.weave.works/blog/practical-guide-gitops) with tools that you love and use on daily-basis, such [Helm](https://helm.sh) and [helmfile](https://github.com/roboll/helmfile) and use custom values and settings that fit to your needs.

Think about this project as a collection of the services you would need to deploy on top of your Kubernetes cluster to enable logging, monitoring, certificate management, automatic discovery of Kubernetes resources via public DNS servers and other common infrastructure needs.

Assumed that you will use the separated terraform configuration for environments (e.g. staging, production). 
This module was designed to use within *staging* environment.
In order to use for production environment you should clone this repo and rename to *production.your_domain*, change a few terraform variables and push changes to a remote origin.

The module supports the following:
- The module creates an AWS EKS cluster for you and add to [Kubernetes clusters](https://docs.gitlab.com/ee/user/group/clusters/#overview) for your GitLab group
- IAM Role with specified policy will be mapped to the cluster-autoscaler service account in kube-system namespace
- Dedicated node group for Gitlab Runner with [scaling a node group to 0](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#scaling-a-node-group-to-0) configuration
- A collection of helmfiles to setup **Gitlab Runner**, **Cluster AutoScaler**, **CertManager**, **NGINX Ingress Contoller**

## Cold start
You should do the manual steps that are described below before to run CI pipeline.

### Prerequisites
- [Amazon AWS account](https://aws.amazon.com/)
- [Amazon CLI](https://aws.amazon.com/cli/)
- [Kubernetes CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [direnv](https://direnv.net/) (v2.15.0)
- [Terraform](https://www.terraform.io/downloads.html) (v0.12.13+)

### DNS requirements
In addition to the requirements listed above, a domain name is also required for setting up Ingress endpoints to services running in the cluster. The specified domain name can be a top-level domain (TLD) or a subdomain. In either case, you have to manually set up the NS records for the specified TLD or subdomain so as to delegate DNS resolution queries to an Amazon Route 53 hosted zone. This is required in order to generate valid TLS certificates.

### Requirements

* clone this repo to your development machine then create a gitlab repo that fits to your `domain name` and `environment`
* create `.env` from `.env.example` and fill `TF_VAR_root_gitlab_project` with the project id from the previous step
* create a [gitlab token](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html) that will be used to connect an AWS EKS cluster to your project and fill `GITLAB_TOKEN` variable in `.env` file (you can add this variable in another way)
* may you need to add `GITLAB_BASE_URL` and other variables to setup properly [Gitlab Terraform Provider](https://www.terraform.io/docs/providers/gitlab/index.html)
* add `AWS_DEFAULT_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `KUBE_INGRESS_BASE_DOMAIN` and `GITLAB_TOKEN` to Gitlab CI environment variables, then mark them as protected and masked 

## Installation and setup
### Step 1: Setup terraform backend.

1.1. Change `./fixtures.eu-central-1.tfvars` according to your requirements, at least, change namespace and stage variables to your own.

```bash
$ cd ./terraform/aws-eks 
$ cp remote-state.tf.example remote-state.tf
$ terraform init
$ terraform apply -var-file ./fixtures.eu-central-1.tfvars -target=module.terraform_state_backend
```

Output:
```bash
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

terraform_backend_config = terraform {
  required_version = ">= 0.12.2"

  backend "s3" {
    region         = "eu-central-1"
    bucket         = "lazyorange-staging-terraform-state"
    key            = "terraform.tfstate"
    dynamodb_table = "lazyorange-staging-terraform-state-lock"
    profile        = ""
    role_arn       = ""
    encrypt        = "true"
  }
}
```

1.2. Add the terraform backend config to remote-state.tf
```bash
$ terraform output terraform_backend_config >> remote-state.tf
```

1.3. Re-run `terraform init` to copy existing state to the remote backend.
```bash
$ terraform init
```

Commit changes to repo and push to remote origin.

### Step 2: Setup AWS Route53

To make possible use [NGinx Ingress Controller](https://github.com/helm/charts/tree/master/stable/nginx-ingress) or another Ingress Controller you should create a hosted zone in [AWS Route53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html), also required by Gitlab to use [Auto DevOps](https://docs.gitlab.com/ee/topics/autodevops/#overview) feature.

### Step 3: Run CI pipeline from master branch 

You can setup other environment variables such as `GITLAB_RUNNER_INSTALLED` to install Gitlab Runner from helm chart and then run CI pipeline from [CI/CD dashboard](https://docs.gitlab.com/ee/ci/pipelines.html#manually-executing-pipelines) to apply changes.

## Components

### Gitlab Runner 

In order to install Gitlab Runner from the helm chart you can add `GITLAB_RUNNER_INSTALLED` environment variable to Gitlab CI/CD variables (should be set to `true`) or add on top of your `.gitlab-ci.yml`

By default Gitlab Runner will be started on [privileged mode](https://docs.gitlab.com/runner/executors/kubernetes.html#using-docker-dind) to be able use Docker in Docker feature to build Docker images with [CPU and RAM limits](/helmfile.d/gitlab/k8s-runner/gitlab-runner.yaml). 

Gitlab Runner Manager will place pods in nodes with the following node affinity condition:
```yaml
affinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: purpose
        operator: NotIn
        values:
        - gitlab-runner
```
By default, the AWS EKS cluster will be provisioned with dedicated node group for Gitlab Runners with min size set to 0.

### Cluster AutoScaler

TBD 

### Ingress stack

- NGINX Ingress Contoller: A Controller to satisfy requests for Ingress objects
- CertManager: A Kubernetes add-on to automate the management and issuance of TLS certificates from various sources

## Contributing

If you would like to become an active contributor to this project please follow the instructions provided in [contribution guidelines](CONTRIBUTING.md).
