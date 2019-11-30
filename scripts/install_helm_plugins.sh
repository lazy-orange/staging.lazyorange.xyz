#!/bin/bash

helm init -c 
helm plugin install https://github.com/rimusz/helm-tiller | echo "Plugin already has been installed"
echo ""
echo "=>"
helm plugin list