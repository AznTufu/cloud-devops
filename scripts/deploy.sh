#!/bin/bash

# Local deployment script with Docker Hub images
# Usage: ./scripts/deploy.sh [DOCKER_USERNAME]

set -e

echo "🚀 Local deployment with Docker Hub images..."

# Variables
DOCKER_USERNAME=${1:-$DOCKER_USERNAME}

if [ -z "$DOCKER_USERNAME" ]; then
    echo "❌ Error: DOCKER_USERNAME required"
    echo "Usage: ./scripts/deploy.sh YOUR_DOCKERHUB_USERNAME"
    echo "Or set DOCKER_USERNAME environment variable"
    exit 1
fi

echo "👤 Docker Hub Username: $DOCKER_USERNAME"

# Check that Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    exit 1
fi

echo "📤 Pulling images from Docker Hub..."
docker pull $DOCKER_USERNAME/cloud-devops-app-backend:latest || {
    echo "❌ Error: Unable to pull server image. Check:"
    echo "   - That image exists on Docker Hub"
    echo "   - That username is correct"
    echo "   - That you are logged into Docker Hub (docker login)"
    exit 1
}

docker pull $DOCKER_USERNAME/cloud-devops-app-frontend:latest || {
    echo "❌ Error: Unable to pull client image"
    exit 1
}

echo "🔄 Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

echo "🚀 Starting with new images..."
DOCKER_USERNAME=$DOCKER_USERNAME docker-compose -f docker-compose.prod.yml up -d

echo "⏳ Waiting for services to start..."
sleep 10

echo "🧹 Cleaning up obsolete images..."
docker system prune -f

echo "✅ Deployment completed!"
echo ""
echo "🌐 Application accessible at:"
echo "   - Frontend: http://localhost"
echo "   - API: http://localhost:3005"
echo "   - Health check: http://localhost:3005/health"

# Health check
echo ""
echo "🏥 Health check of services..."

# Wait a bit more for services to start
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
echo "📊 Container status:"
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "📝 To view logs:"
echo "   docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "🛑 To stop application:"
echo "   docker-compose -f docker-compose.prod.yml down"
