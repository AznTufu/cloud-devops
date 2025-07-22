# Script PowerShell pour construire et pousser les images Docker vers Docker Hub
# Usage: .\build-and-push.ps1 [docker-hub-username]

param(
    [string]$DockerHubUsername = "VOTRE_USERNAME_DOCKERHUB"
)

$APP_NAME = "cloud-devops-app"

Write-Host "🐳 Construction et push des images Docker..." -ForegroundColor Green

# Vérifier que Docker est installé
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker n'est pas installé" -ForegroundColor Red
    exit 1
}

# Se déplacer dans le répertoire du projet
Set-Location $PSScriptRoot\..\..

Write-Host "📦 Construction de l'image frontend..." -ForegroundColor Yellow
docker build -t "${DockerHubUsername}/${APP_NAME}-frontend:latest" ./client

Write-Host "📦 Construction de l'image backend..." -ForegroundColor Yellow
docker build -t "${DockerHubUsername}/${APP_NAME}-backend:latest" ./server

Write-Host "🔐 Connexion à Docker Hub (veuillez entrer vos identifiants)..." -ForegroundColor Blue
docker login

Write-Host "⬆️ Push de l'image frontend..." -ForegroundColor Cyan
docker push "${DockerHubUsername}/${APP_NAME}-frontend:latest"

Write-Host "⬆️ Push de l'image backend..." -ForegroundColor Cyan
docker push "${DockerHubUsername}/${APP_NAME}-backend:latest"

Write-Host "✅ Images poussées avec succès vers Docker Hub!" -ForegroundColor Green
Write-Host "Frontend: ${DockerHubUsername}/${APP_NAME}-frontend:latest" -ForegroundColor White
Write-Host "Backend: ${DockerHubUsername}/${APP_NAME}-backend:latest" -ForegroundColor White
