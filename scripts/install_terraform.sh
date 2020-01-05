#!/bin/bash

# https://www.terraform.io/downloads.html

export TERRAFORM_VERSION=${TERRAFORM_VERSION:-0.12.13}
export WORKDIR=/tmp/terraform

rm -rf $WORKDIR && mkdir -p $WORKDIR && cd $WORKDIR

wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

mv $WORKDIR/terraform /usr/local/bin/terraform
chmod +x /usr/local/bin/terraform

rm -rf $WORKDIR

terraform version