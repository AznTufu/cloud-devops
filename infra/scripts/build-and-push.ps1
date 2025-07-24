# PowerShell script to build and push Docker images to Docker Hub
# Usage: .\build-and-push.ps1 [docker-hub-username]

param(
    [string]$DockerHubUsername = "YOUR_DOCKERHUB_USERNAME"
)

$APP_NAME = "cloud-devops-app"

Write-Host "Building and pushing Docker images..." -ForegroundColor Green

# Check that Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed" -ForegroundColor Red
    exit 1
}

# Move to project directory
Set-Location $PSScriptRoot\..\..

Write-Host "Building frontend image..." -ForegroundColor Yellow
docker build -t "${DockerHubUsername}/${APP_NAME}-frontend:latest" ./client

Write-Host "Building backend image..." -ForegroundColor Yellow  
docker build -t "${DockerHubUsername}/${APP_NAME}-backend:latest" ./server

Write-Host "Logging into Docker Hub (please enter your credentials)..." -ForegroundColor Blue
docker login

Write-Host "Pushing frontend image..." -ForegroundColor Cyan
docker push "${DockerHubUsername}/${APP_NAME}-frontend:latest"

Write-Host "Pushing backend image..." -ForegroundColor Cyan
docker push "${DockerHubUsername}/${APP_NAME}-backend:latest"

Write-Host "Images pushed successfully to Docker Hub!" -ForegroundColor Green
Write-Host "Frontend: ${DockerHubUsername}/${APP_NAME}-frontend:latest" -ForegroundColor White
Write-Host "Backend: ${DockerHubUsername}/${APP_NAME}-backend:latest" -ForegroundColor White
