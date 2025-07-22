# Script de déploiement local pour Windows
# Usage: .\scripts\deploy.ps1 -DockerUsername "VOTRE_USERNAME"

param(
    [Parameter(Mandatory=$true)]
    [string]$DockerUsername
)

Write-Host "🚀 Déploiement local avec les images Docker Hub..." -ForegroundColor Green

Write-Host "👤 Docker Hub Username: $DockerUsername" -ForegroundColor Cyan

# Vérification que Docker est en cours d'exécution
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Erreur: Docker n'est pas en cours d'exécution" -ForegroundColor Red
    exit 1
}

Write-Host "📤 Pulling des images depuis Docker Hub..." -ForegroundColor Yellow

try {
    docker pull "$DockerUsername/cloud-devops-app-backend:latest"
    docker pull "$DockerUsername/cloud-devops-app-frontend:latest"
} catch {
    Write-Host "❌ Erreur: Impossible de pull les images. Vérifiez:" -ForegroundColor Red
    Write-Host "   - Que les images existent sur Docker Hub" -ForegroundColor Red
    Write-Host "   - Que le nom d'utilisateur est correct" -ForegroundColor Red
    Write-Host "   - Que vous êtes connecté à Docker Hub (docker login)" -ForegroundColor Red
    exit 1
}

Write-Host "🔄 Arrêt des conteneurs existants..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml down 2>$null

Write-Host "🚀 Démarrage avec les nouvelles images..." -ForegroundColor Green
$env:DOCKER_USERNAME = $DockerUsername
docker-compose -f docker-compose.prod.yml up -d

Write-Host "⏳ Attente du démarrage des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "🧹 Nettoyage des images obsolètes..." -ForegroundColor Yellow
docker system prune -f

Write-Host "✅ Déploiement terminé!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Application accessible sur:" -ForegroundColor Cyan
Write-Host "   - Frontend: http://localhost" -ForegroundColor White
Write-Host "   - API: http://localhost:3005" -ForegroundColor White
Write-Host "   - Health check: http://localhost:3005/health" -ForegroundColor White

# Vérification de santé
Write-Host ""
Write-Host "🏥 Vérification de santé des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Test API Health
try {
    Invoke-WebRequest -Uri "http://localhost:3005/health" -Method Get -TimeoutSec 5 | Out-Null
    Write-Host "   ✅ API: Healthy" -ForegroundColor Green
} catch {
    Write-Host "   ❌ API: Unhealthy" -ForegroundColor Red
}

# Test Frontend
try {
    Invoke-WebRequest -Uri "http://localhost" -Method Get -TimeoutSec 5 | Out-Null
    Write-Host "   ✅ Frontend: Healthy" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Frontend: Unhealthy" -ForegroundColor Red
}

Write-Host ""
Write-Host "📊 Status des conteneurs:" -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml ps

Write-Host ""
Write-Host "📝 Pour voir les logs:" -ForegroundColor Yellow
Write-Host "   docker-compose -f docker-compose.prod.yml logs -f" -ForegroundColor White
Write-Host ""
Write-Host "🛑 Pour arrêter l'application:" -ForegroundColor Yellow
Write-Host "   docker-compose -f docker-compose.prod.yml down" -ForegroundColor White
