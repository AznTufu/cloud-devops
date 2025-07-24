# Local deployment script for Windows
# Usage: .\scripts\deploy.ps1 -DockerUsername "YOUR_USERNAME"

param(
    [Parameter(Mandatory=$true)]
    [string]$DockerUsername
)

Write-Host "🚀 Local deployment with Docker Hub images..." -ForegroundColor Green

Write-Host "👤 Docker Hub Username: $DockerUsername" -ForegroundColor Cyan

# Check that Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Error: Docker is not running" -ForegroundColor Red
    exit 1
}

Write-Host "📤 Pulling images from Docker Hub..." -ForegroundColor Yellow

try {
    docker pull "$DockerUsername/cloud-devops-app-backend:latest"
    docker pull "$DockerUsername/cloud-devops-app-frontend:latest"
} catch {
    Write-Host "❌ Error: Unable to pull images. Check:" -ForegroundColor Red
    Write-Host "   - That images exist on Docker Hub" -ForegroundColor Red
    Write-Host "   - That username is correct" -ForegroundColor Red
    Write-Host "   - That you are logged into Docker Hub (docker login)" -ForegroundColor Red
    exit 1
}

Write-Host "🔄 Stopping existing containers..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml down 2>$null

Write-Host "🚀 Starting with new images..." -ForegroundColor Green
$env:DOCKER_USERNAME = $DockerUsername
docker-compose -f docker-compose.prod.yml up -d

Write-Host "⏳ Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "🧹 Cleaning up obsolete images..." -ForegroundColor Yellow
docker system prune -f

Write-Host "✅ Deployment completed!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Application accessible at:" -ForegroundColor Cyan
Write-Host "   - Frontend: http://localhost" -ForegroundColor White
Write-Host "   - API: http://localhost:3005" -ForegroundColor White
Write-Host "   - Health check: http://localhost:3005/health" -ForegroundColor White

# Health check
Write-Host ""
Write-Host "🏥 Health check of services..." -ForegroundColor Yellow
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
Write-Host "📊 Container status:" -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml ps

Write-Host ""
Write-Host "📝 To view logs:" -ForegroundColor Yellow
Write-Host "   docker-compose -f docker-compose.prod.yml logs -f" -ForegroundColor White
Write-Host ""
Write-Host "🛑 To stop application:" -ForegroundColor Yellow
Write-Host "   docker-compose -f docker-compose.prod.yml down" -ForegroundColor White
