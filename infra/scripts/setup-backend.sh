#!/bin/bash
# Script pour initialiser le backend S3 Terraform
# EXÉCUTER UNE SEULE FOIS avant d'utiliser le pipeline

echo "🚀 Initialisation du backend Terraform S3..."

# Vérifier que les credentials AWS sont configurés
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ Erreur: AWS credentials non configurés"
    echo "Configurez vos credentials avec: aws configure"
    exit 1
fi

echo "✅ Credentials AWS OK"

# Se déplacer dans le dossier bootstrap
cd "$(dirname "$0")/../backend"

echo "🔧 Initialisation Terraform pour le bootstrap..."
terraform init

echo "📋 Planification de l'infrastructure backend..."
terraform plan

echo "🏗️ Création du bucket S3 et de la table DynamoDB..."
terraform apply -auto-approve

echo "✅ Backend S3 créé avec succès!"
echo ""
echo "📝 Prochaines étapes:"
echo "1. Votre bucket S3 et table DynamoDB sont créés"
echo "2. Le pipeline GitHub Actions utilisera automatiquement ce backend"
echo "3. Vous pouvez maintenant pousser sur main pour déclencher le déploiement"
echo ""
echo "🎯 Ressources créées:"
terraform output
