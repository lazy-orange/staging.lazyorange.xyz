#!/bin/bash

./scripts/destroy_helm_releases.sh
cd terraform/doks && terraform destroy -var-file fra1.tfvars -auto-approve