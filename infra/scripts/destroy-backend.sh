#!/bin/bash
# 🗑️ Terraform S3 Backend Destruction
# WARNING: Removes S3 bucket and all Terraform states!

set -e

echo "⚠️  DESTROYING Terraform S3 backend"
echo ""
echo "This will delete:"
echo "  - S3 bucket with all Terraform states"
echo "  - DynamoDB lock table"
echo ""

read -p "Type 'DESTROY' to confirm destruction: " confirm
if [ "$confirm" != "DESTROY" ]; then
    echo "✅ Destruction cancelled"
    exit 0
fi

# Check AWS credentials
if aws sts get-caller-identity >/dev/null 2>&1; then
    ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    echo "✅ AWS connected - Account: $ACCOUNT"
else
    echo "❌ AWS credentials not configured"
    exit 1
fi

# Go to backend directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../backend"

echo "🔧 Initializing Terraform..."
terraform init -upgrade >/dev/null 2>&1

# Get bucket name and empty contents
if BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null); then
    echo "🗂️ Emptying bucket: $BUCKET_NAME"
    aws s3 rm "s3://$BUCKET_NAME" --recursive
else
    echo "⚠️ Trying with default name"
    aws s3 rm s3://cloud-devops-terraform-state-bucket --recursive
fi

echo "🔨 Destroying resources..."
terraform destroy -auto-approve

echo ""
echo "✅ S3 backend destroyed successfully!"
