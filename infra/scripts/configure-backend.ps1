# Script PowerShell de configuration automatique du backend S3 pour la CI/CD
# Ce script verifie et configure le backend S3 si necessaire

$ErrorActionPreference = "Stop"

$BUCKET_NAME = "cloud-devops-terraform-state-bucket"
$DYNAMODB_TABLE = "terraform-state-lock"
$REGION = "eu-west-1"

Write-Host "Verification du backend S3 Terraform..." -ForegroundColor Blue

# Verifier si le bucket existe
try {
    aws s3 ls "s3://$BUCKET_NAME" | Out-Null
    Write-Host "Le bucket S3 '$BUCKET_NAME' existe deja" -ForegroundColor Green
    
    # Verifier si la table DynamoDB existe
    try {
        aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$REGION" | Out-Null
        Write-Host "La table DynamoDB '$DYNAMODB_TABLE' existe deja" -ForegroundColor Green
        Write-Host "Backend S3 completement configure" -ForegroundColor Green
        exit 0
    } catch {
        Write-Host "Table DynamoDB manquante, creation necessaire..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Bucket S3 manquant, creation necessaire..." -ForegroundColor Yellow
}

Write-Host "Configuration du backend S3 necessaire..." -ForegroundColor Blue

# Se deplacer vers le dossier backend
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$backendPath = "$scriptPath\..\backend"
Set-Location $backendPath

Write-Host "Initialisation de Terraform..." -ForegroundColor Blue
terraform init

Write-Host "Planification de l'infrastructure backend..." -ForegroundColor Blue
terraform plan -out=backend.tfplan

Write-Host "Creation des ressources backend..." -ForegroundColor Blue
terraform apply -auto-approve backend.tfplan

Write-Host "Backend S3 configure avec succes!" -ForegroundColor Green

# Afficher les outputs
Write-Host ""
Write-Host "Informations du backend cree:" -ForegroundColor Cyan
terraform output

Write-Host ""
Write-Host "Le backend S3 est maintenant pret pour vos deploiements Terraform" -ForegroundColor Green
