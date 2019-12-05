FROM registry.gitlab.com/gitlab-org/cluster-integration/auto-deploy-image:v0.4.0

ADD scripts /scripts

# ==> Install Terraform
ARG terraform_ver=0.12.13
ENV TERRAFORM_VERSION $terraform_ver

RUN apk add unzip
RUN curl -LO https://raw.github.com/robertpeteuil/terraform-installer/master/terraform-install.sh && chmod +x terraform-install.sh
RUN ./terraform-install.sh -i $TERRAFORM_VERSION
# Check that it's installed
RUN terraform --version 

# ==> Install helmfile
ARG helmfile_ver=v0.89.0
ENV HELMFILE_VERSION $helmfile_ver
RUN /scripts/install_helmfile.sh

# ==> Install AWS cli
RUN apk -Uuv add groff less python py-pip
RUN pip install awscli
RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*

# ==> Install jq
ADD https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 /usr/local/bin/jq
RUN chmod +x /usr/local/bin/jq && jq --version

ADD helmfile.d /etc/helmfile.d