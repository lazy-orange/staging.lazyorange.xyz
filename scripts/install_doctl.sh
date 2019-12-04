#!/bin/bash

export DOCTL_VERSION="1.34.0"

curl -sL https://github.com/digitalocean/doctl/releases/download/v$DOCTL_VERSION/doctl-$DOCTL_VERSION-linux-amd64.tar.gz | tar -xzv
mv ./doctl /usr/local/bin

doctl version