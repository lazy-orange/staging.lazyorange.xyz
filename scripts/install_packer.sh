#!/bin/bash

set -o pipefail

export PACKER_VERSION=${PACKER_VER:-"1.5.1"}
export WORKDIR=/tmp/packer

rm -rf $WORKDIR && mkdir -p $WORKDIR && cd $WORKDIR

wget "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip"
unzip "packer_${PACKER_VERSION}_linux_amd64.zip"

mv $WORKDIR/packer /usr/local/bin/packer
chmod +x /usr/local/bin/packer

packer version