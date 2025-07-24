# Terraform S3 Backend Creation
# Execute ONLY ONCE before using S3 backend

Write-Host "Creating Terraform S3 backend..." -ForegroundColor Green

# Check AWS credentials
try {
    $identity = aws sts get-caller-identity --output json | ConvertFrom-Json
    Write-Host "AWS connected - Account: $($identity.Account)" -ForegroundColor Green
} catch {
    Write-Host "AWS credentials not configured" -ForegroundColor Red
    Write-Host "Run: aws configure" -ForegroundColor Yellow
    exit 1
}

# Go to backend directory
$backendPath = "$PSScriptRoot\..\backend"
Set-Location $backendPath

Write-Host "Initializing Terraform..." -ForegroundColor Blue
terraform init -upgrade

Write-Host "Planning..." -ForegroundColor Blue
terraform plan

Write-Host "Creating S3 bucket and DynamoDB..." -ForegroundColor Blue
terraform apply -auto-approve

Write-Host ""
Write-Host "S3 backend created successfully!" -ForegroundColor Green
Write-Host "Resources created:" -ForegroundColor Cyan
terraform output

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Push your code to GitHub" -ForegroundColor White
Write-Host "  2. Pipeline will automatically use this backend" -ForegroundColor White
