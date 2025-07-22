#!/bin/bash

# Script de déploiement local avec les images Docker Hub
# Usage: ./scripts/deploy.sh [DOCKER_USERNAME]

set -e

echo "🚀 Déploiement local avec les images Docker Hub..."

# Variables
DOCKER_USERNAME=${1:-$DOCKER_USERNAME}

if [ -z "$DOCKER_USERNAME" ]; then
    echo "❌ Erreur: DOCKER_USERNAME requis"
    echo "Usage: ./scripts/deploy.sh VOTRE_USERNAME_DOCKERHUB"
    echo "Ou définissez la variable d'environnement DOCKER_USERNAME"
    exit 1
fi

echo "👤 Docker Hub Username: $DOCKER_USERNAME"

# Vérification que Docker est en cours d'exécution
if ! docker info >/dev/null 2>&1; then
    echo "❌ Erreur: Docker n'est pas en cours d'exécution"
    exit 1
fi

echo "📤 Pulling des images depuis Docker Hub..."
docker pull $DOCKER_USERNAME/cloud-devops-app-backend:latest || {
    echo "❌ Erreur: Impossible de pull l'image server. Vérifiez:"
    echo "   - Que l'image existe sur Docker Hub"
    echo "   - Que le nom d'utilisateur est correct"
    echo "   - Que vous êtes connecté à Docker Hub (docker login)"
    exit 1
}

docker pull $DOCKER_USERNAME/cloud-devops-app-frontend:latest || {
    echo "❌ Erreur: Impossible de pull l'image client"
    exit 1
}

echo "🔄 Arrêt des conteneurs existants..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

echo "🚀 Démarrage avec les nouvelles images..."
DOCKER_USERNAME=$DOCKER_USERNAME docker-compose -f docker-compose.prod.yml up -d

echo "⏳ Attente du démarrage des services..."
sleep 10

echo "🧹 Nettoyage des images obsolètes..."
docker system prune -f

echo "✅ Déploiement terminé!"
echo ""
echo "🌐 Application accessible sur:"
echo "   - Frontend: http://localhost"
echo "   - API: http://localhost:3005"
echo "   - Health check: http://localhost:3005/health"

# Vérification de santé
echo ""
echo "🏥 Vérification de santé des services..."

# Attendre un peu plus pour que les services démarrent
sleep 5

# Test API Health
if curl -f -s http://localhost:3005/health >/dev/null 2>&1; then
    echo "   ✅ API: Healthy"
else
    echo "   ❌ API: Unhealthy"
fi

# Test Frontend
if curl -f -s http://localhost >/dev/null 2>&1; then
    echo "   ✅ Frontend: Healthy"
else
    echo "   ❌ Frontend: Unhealthy"
fi

echo ""
echo "📊 Status des conteneurs:"
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "📝 Pour voir les logs:"
echo "   docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "🛑 Pour arrêter l'application:"
echo "   docker-compose -f docker-compose.prod.yml down"
