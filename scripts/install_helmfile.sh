#!/bin/bash

export HELMFILE_VERSION=${HELMFILE_VERSION:-"v0.89.0"}
export WORKDIR=/tmp/helmfile

rm -rf $WORKDIR && mkdir -p $WORKDIR && cd $WORKDIR

wget https://github.com/roboll/helmfile/releases/download/$HELMFILE_VERSION/helmfile_linux_amd64
mv helmfile_linux_amd64 /usr/local/bin/helmfile
chmod +x /usr/local/bin/helmfile

rm -rf $WORKDIR

helmfile --version