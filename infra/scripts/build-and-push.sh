#!/bin/bash

# Script to build and push Docker images to Docker Hub
# Usage: ./build-and-push.sh [docker-hub-username]

set -e

DOCKER_HUB_USERNAME=${1:-"YOUR_DOCKERHUB_USERNAME"}
APP_NAME="cloud-devops-app"

echo "🐳 Building and pushing Docker images..."

# Check that Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

# Move to project directory
cd "$(dirname "$0")/../.."

echo "📦 Building frontend image..."
docker build -t ${DOCKER_HUB_USERNAME}/${APP_NAME}-frontend:latest ./client

echo "📦 Building backend image..."
docker build -t ${DOCKER_HUB_USERNAME}/${APP_NAME}-backend:latest ./server

echo "🔐 Logging into Docker Hub (please enter your credentials)..."
docker login

echo "⬆️ Pushing frontend image..."
docker push ${DOCKER_HUB_USERNAME}/${APP_NAME}-frontend:latest

echo "⬆️ Pushing backend image..."
docker push ${DOCKER_HUB_USERNAME}/${APP_NAME}-backend:latest

echo "✅ Images pushed successfully to Docker Hub!"
echo "Frontend: ${DOCKER_HUB_USERNAME}/${APP_NAME}-frontend:latest"
echo "Backend: ${DOCKER_HUB_USERNAME}/${APP_NAME}-backend:latest"
