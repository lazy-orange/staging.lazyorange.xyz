#!/bin/bash

export EKSCTL_VERSION=0.5.3
export WORKDIR=/tmp/eksctl

rm -rf $WORKDIR && mkdir -p $WORKDIR && cd $WORKDIR

curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C $WORKDIR
mv $WORKDIR/eksctl /usr/local/bin
chmod +x /usr/local/bin/eksctl

rm -rf $WORKDIR

eksctl version