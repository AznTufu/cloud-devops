#!/bin/bash
# Script de configuration automatique du backend S3 pour la CI/CD
# Ce script vérifie et configure le backend S3 si nécessaire

set -e

BUCKET_NAME="cloud-devops-terraform-state-bucket"
DYNAMODB_TABLE="terraform-state-lock"
REGION="eu-west-1"

echo "🔍 Vérification du backend S3 Terraform..."

# Vérifier si le bucket existe
if aws s3 ls "s3://$BUCKET_NAME" >/dev/null 2>&1; then
    echo "✅ Le bucket S3 '$BUCKET_NAME' existe déjà"
    
    # Vérifier si la table DynamoDB existe
    if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$REGION" >/dev/null 2>&1; then
        echo "✅ La table DynamoDB '$DYNAMODB_TABLE' existe déjà"
        echo "✅ Backend S3 complètement configuré"
        exit 0
    fi
fi

echo "🚀 Configuration du backend S3 nécessaire..."

# Se déplacer vers le dossier backend
cd "$(dirname "$0")/../backend"

echo "🔄 Initialisation de Terraform..."
terraform init

echo "📋 Planification de l'infrastructure backend..."
terraform plan -out=backend.tfplan

echo "🚀 Création des ressources backend..."
terraform apply -auto-approve backend.tfplan

echo "✅ Backend S3 configuré avec succès!"

# Afficher les outputs
echo ""
echo "📊 Informations du backend créé:"
terraform output

echo ""
echo "💡 Le backend S3 est maintenant prêt pour vos déploiements Terraform"
