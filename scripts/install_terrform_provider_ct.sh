#!/bin/bash

export TERRAFORM_CT_VER=v0.4.0

wget "https://github.com/poseidon/terraform-provider-ct/releases/download/${TERRAFORM_CT_VER}/terraform-provider-ct-${TERRAFORM_CT_VER}-linux-amd64.tar.gz"
tar xzf terraform-provider-ct-${TERRAFORM_CT_VER}-linux-amd64.tar.gz
mv terraform-provider-ct-${TERRAFORM_CT_VER}-linux-amd64/terraform-provider-ct ~/.terraform.d/plugins/terraform-provider-ct_${TERRAFORM_CT_VER}
rm -rf terraform-provider-ct-${TERRAFORM_CT_VER}-linux-amd64