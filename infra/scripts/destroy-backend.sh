#!/bin/bash
# Script pour détruire l'infrastructure backend S3 Terraform
# ATTENTION: Cela supprimera le bucket S3 et tous les states Terraform stockés !

echo "ATTENTION: Destruction du backend Terraform S3..."
echo "Cela va supprimer:"
echo "- Le bucket S3 avec tous les states Terraform"
echo "- La table DynamoDB de locking"
echo ""
read -p "Êtes-vous sûr de vouloir continuer? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Annulation de la destruction."
    exit 0
fi

# Vérifier que les credentials AWS sont configurés
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "Erreur: AWS credentials non configurés"
    echo "Configurez vos credentials avec: aws configure"
    exit 1
fi

echo "Credentials AWS OK"

# Se déplacer dans le dossier backend
cd "$(dirname "$0")/../backend"

echo "Réinitialisation de Terraform..."
rm -rf .terraform .terraform.lock.hcl
terraform init

echo "Vider le bucket S3 avant destruction..."
aws s3 rm s3://cloud-devops-terraform-state-bucket --recursive

echo "Destruction de l'infrastructure backend..."
terraform destroy -auto-approve

echo "Backend S3 détruit avec succès!"
echo "Vous pouvez maintenant relancer setup-backend.sh"
