#!/bin/bash

# Navigate to the Terraform directory
cd ../terraform

# Initialize Terraform
terraform init

# Validate the Terraform configuration
terraform validate

# Apply the Terraform configuration
terraform apply -auto-approve

# Output the URL of the deployed application
echo "Deployment complete. Access your application at:"
terraform output application_url