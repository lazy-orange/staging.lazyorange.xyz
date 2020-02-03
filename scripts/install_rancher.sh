#!/bin/bash

helm tiller start-ci
helm ls

helmfile -l component=cert-manager sync
helmfile -l chart=nginx-ingress sync
helmfile -l chart=rancher sync