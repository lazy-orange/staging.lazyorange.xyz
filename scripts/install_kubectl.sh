#!/bin/bash

# https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux

export KUBECTL_VERSION=${KUBECTL_VERSION:-"v1.16.0"}
export WORKDIR=/tmp/kubectl

rm -rf $WORKDIR && mkdir -p $WORKDIR && cd $WORKDIR

curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
mv $WORKDIR/kubectl /usr/local/bin
chmod +x /usr/local/bin/kubectl

rm -rf $WORKDIR

echo " "
echo "=> kubectl version"
kubectl version --client=true