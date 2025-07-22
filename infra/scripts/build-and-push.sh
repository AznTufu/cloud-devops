#!/bin/bash

# Script pour construire et pousser les images Docker vers Docker Hub
# Usage: ./build-and-push.sh [docker-hub-username]

set -e

DOCKER_HUB_USERNAME=${1:-"VOTRE_USERNAME_DOCKERHUB"}
APP_NAME="cloud-devops-app"

echo "🐳 Construction et push des images Docker..."

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    exit 1
fi

# Se déplacer dans le répertoire du projet
cd "$(dirname "$0")/../.."

echo "📦 Construction de l'image frontend..."
docker build -t ${DOCKER_HUB_USERNAME}/${APP_NAME}-frontend:latest ./client

echo "📦 Construction de l'image backend..."
docker build -t ${DOCKER_HUB_USERNAME}/${APP_NAME}-backend:latest ./server

echo "🔐 Connexion à Docker Hub (veuillez entrer vos identifiants)..."
docker login

echo "⬆️ Push de l'image frontend..."
docker push ${DOCKER_HUB_USERNAME}/${APP_NAME}-frontend:latest

echo "⬆️ Push de l'image backend..."
docker push ${DOCKER_HUB_USERNAME}/${APP_NAME}-backend:latest

echo "✅ Images poussées avec succès vers Docker Hub!"
echo "Frontend: ${DOCKER_HUB_USERNAME}/${APP_NAME}-frontend:latest"
echo "Backend: ${DOCKER_HUB_USERNAME}/${APP_NAME}-backend:latest"
