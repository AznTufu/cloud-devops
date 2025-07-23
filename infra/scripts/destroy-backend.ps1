# Script PowerShell pour detruire l'infrastructure backend S3 Terraform
# ATTENTION: Cela supprimera le bucket S3 et tous les states Terraform stockes !

Write-Host "ATTENTION: Destruction du backend Terraform S3..." -ForegroundColor Red
Write-Host "Cela va supprimer:" -ForegroundColor Yellow
Write-Host "- Le bucket S3 avec tous les states Terraform"
Write-Host "- La table DynamoDB de locking"
Write-Host ""

$confirm = Read-Host "Etes-vous sur de vouloir continuer? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Annulation de la destruction." -ForegroundColor Green
    exit 0
}

# Verifier que les credentials AWS sont configures
try {
    aws sts get-caller-identity | Out-Null
    Write-Host "Credentials AWS OK" -ForegroundColor Green
} catch {
    Write-Host "Erreur: AWS credentials non configures" -ForegroundColor Red
    Write-Host "Configurez vos credentials avec: aws configure" -ForegroundColor Yellow
    exit 1
}

# Se deplacer dans le dossier backend
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location "$scriptPath\..\backend"

Write-Host "Reinitialisation de Terraform..." -ForegroundColor Blue
Remove-Item -Path ".terraform" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".terraform.lock.hcl" -Force -ErrorAction SilentlyContinue
terraform init

Write-Host "Vidage du bucket S3 avant destruction..." -ForegroundColor Blue
aws s3 rm s3://cloud-devops-terraform-state-bucket --recursive

Write-Host "Destruction de l'infrastructure backend..." -ForegroundColor Blue
terraform destroy -auto-approve

Write-Host "Backend S3 detruit avec succes!" -ForegroundColor Green
Write-Host "Vous pouvez maintenant relancer setup-backend.ps1" -ForegroundColor Yellow
