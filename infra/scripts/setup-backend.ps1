# Script PowerShell pour initialiser le backend S3 Terraform
# EXECUTER UNE SEULE FOIS avant d'utiliser le pipeline

Write-Host "Initialisation du backend Terraform S3..." -ForegroundColor Green

# Verifier que les credentials AWS sont configures
try {
    aws sts get-caller-identity | Out-Null
    Write-Host "Credentials AWS OK" -ForegroundColor Green
} catch {
    Write-Host "Erreur: AWS credentials non configures" -ForegroundColor Red
    Write-Host "Configurez vos credentials avec: aws configure" -ForegroundColor Yellow
    exit 1
}

# Se deplacer dans le dossier bootstrap
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location "$scriptPath\..\backend"

Write-Host "Initialisation Terraform pour le bootstrap..." -ForegroundColor Blue
terraform init

Write-Host "Planification de l'infrastructure backend..." -ForegroundColor Blue
terraform plan

Write-Host "Creation du bucket S3 et de la table DynamoDB..." -ForegroundColor Blue
terraform apply -auto-approve

Write-Host "Backend S3 cree avec succes!" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines etapes:" -ForegroundColor Yellow
Write-Host "1. Votre bucket S3 et table DynamoDB sont crees"
Write-Host "2. Le pipeline GitHub Actions utilisera automatiquement ce backend"
Write-Host "3. Vous pouvez maintenant pousser sur main pour declencher le deploiement"
Write-Host ""
Write-Host "Ressources creees:" -ForegroundColor Cyan
terraform output
