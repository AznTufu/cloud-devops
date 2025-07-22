#!/bin/bash

# This script cleans up the deployed infrastructure by destroying the resources created by Terraform.

set -e

# Navigate to the Terraform directory
cd ../terraform

# Run Terraform destroy command to remove the infrastructure
terraform destroy -auto-approve

# Optionally, remove the Terraform state files if needed
# rm -rf .terraform
# rm -f terraform.tfstate
# rm -f terraform.tfstate.backup

echo "Cleanup completed."