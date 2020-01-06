FROM bitnami/minideb:stretch
RUN apt-get update && apt-get install -qy wget unzip curl git

ADD scripts /scripts

ARG kubectl_ver=v1.16.0
ENV KUBECTL_VERSION $kubectl_ver
RUN /scripts/install_kubectl.sh

# ==> Install Helm
ARG helm_ver=v2.15.1
ENV HELM_VER $helm_ver
RUN /scripts/install_helm.sh

# ==> Install Terraform
ARG terraform_ver=0.12.18
ENV TERRAFORM_VERSION $terraform_ver

RUN curl -LO https://raw.github.com/robertpeteuil/terraform-installer/master/terraform-install.sh && chmod +x terraform-install.sh
RUN ./terraform-install.sh -i $TERRAFORM_VERSION
# Check that it's installed
RUN terraform --version 

RUN helm init -c && helm plugin install https://github.com/rimusz/helm-tiller

# ==> Install helmfile
ARG helmfile_ver=v0.94.1
ENV HELMFILE_VERSION $helmfile_ver
RUN /scripts/install_helmfile.sh

# ==> Install AWS cli 
# It increases image size from 393MB to 778MB
# and as a result increases the bootstrap process of Gitlab CI job
RUN apt-get install python python-pip -qy
RUN pip install awscli

# ==> Install doctl
ARG doctl_ver=1.36.0
ENV DOCTL_VERSION $doctl_ver
RUN ./scripts/install_doctl.sh

# ==> Install jq
ADD https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 /usr/local/bin/jq
RUN chmod +x /usr/local/bin/jq && jq --version

# ==> Install zsh (not required by Gitlab Pipelines)
RUN apt-get install zsh -yq && sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN apt-get remove -qy wget git unzip python-pip && apt-get clean