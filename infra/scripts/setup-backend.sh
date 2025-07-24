#!/bin/bash
# 🚀 Terraform S3 Backend Creation
# Execute ONLY ONCE before using S3 backend

set -e

echo "🚀 Creating Terraform S3 backend..."

# Check AWS credentials
if aws sts get-caller-identity >/dev/null 2>&1; then
    ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    echo "✅ AWS connected - Account: $ACCOUNT"
else
    echo "❌ AWS credentials not configured"
    echo "💡 Run: aws configure"
    exit 1
fi

# Go to backend directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../backend"

echo "🔧 Initializing Terraform..."
terraform init -upgrade

echo "📋 Planning..."
terraform plan -out=backend.tfplan

echo "🏗️ Creating S3 bucket and DynamoDB..."
terraform apply -auto-approve backend.tfplan

echo ""
echo "✅ S3 backend created successfully!"
echo "📊 Resources created:"
terraform output

echo ""
echo "🎯 Next steps:"
echo "  1. Push your code to GitHub"
echo "  2. Pipeline will automatically use this backend"
