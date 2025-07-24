# Terraform S3 Backend Destruction
# WARNING: This will destroy the S3 bucket and DynamoDB table!

Write-Host "Destroying Terraform S3 backend..." -ForegroundColor Yellow

# Navigate to backend directory
$backendPath = "$PSScriptRoot\..\backend"
Set-Location $backendPath

# Initialize Terraform
Write-Host "Initializing Terraform..." -ForegroundColor Cyan
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error during Terraform initialization" -ForegroundColor Red
    exit 1
}

# Plan destruction
Write-Host "Planning destruction..." -ForegroundColor Cyan
terraform plan -destroy
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error during destruction planning" -ForegroundColor Red
    exit 1
}

# Ask for confirmation
$confirmation = Read-Host "Do you really want to destroy the S3 backend? (yes/no)"
if ($confirmation -ne "yes") {
    Write-Host "Destruction cancelled." -ForegroundColor Yellow
    exit 0
}

# Empty S3 bucket before destruction (versioning management)
Write-Host "Emptying S3 bucket (all versions)..." -ForegroundColor Cyan
$bucket = "cloud-devops-terraform-state-bucket"

# Check if bucket exists
try {
    aws s3api head-bucket --bucket $bucket 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Deleting all object versions in bucket..." -ForegroundColor Yellow
        
        # Get all versions
        $versionsJson = aws s3api list-object-versions --bucket $bucket --output json
        if ($versionsJson) {
            $versions = $versionsJson | ConvertFrom-Json
            
            # Delete all object versions
            if ($versions.Versions) {
                foreach ($version in $versions.Versions) {
                    aws s3api delete-object --bucket $bucket --key $version.Key --version-id $version.VersionId > $null
                }
                Write-Host "Object versions deleted." -ForegroundColor Green
            }
            
            # Delete all delete markers
            if ($versions.DeleteMarkers) {
                foreach ($deleteMarker in $versions.DeleteMarkers) {
                    aws s3api delete-object --bucket $bucket --key $deleteMarker.Key --version-id $deleteMarker.VersionId > $null
                }
                Write-Host "Delete markers removed." -ForegroundColor Green
            }
        }
        
        # Delete remaining objects (just in case)
        aws s3 rm s3://$bucket --recursive > $null 2>&1
        Write-Host "S3 bucket emptied successfully." -ForegroundColor Green
    } else {
        Write-Host "S3 bucket doesn't exist or is already deleted." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error emptying S3 bucket, but continuing..." -ForegroundColor Yellow
}

# Destroy infrastructure
Write-Host "Destroying infrastructure..." -ForegroundColor Red
terraform destroy -auto-approve
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error during destruction" -ForegroundColor Red
    exit 1
}

Write-Host "S3 backend destroyed successfully!" -ForegroundColor Green

# Return to scripts directory
$scriptsPath = "$PSScriptRoot"
Set-Location $scriptsPath
