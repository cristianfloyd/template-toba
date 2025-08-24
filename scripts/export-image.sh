#!/bin/bash

# Script para exportar la imagen de desarrollo Toba configurada
# Este script crea una imagen Docker con toda la aplicación Toba instalada

set -e

echo "🚀 Exportando imagen de desarrollo Toba..."

# Verificar que los contenedores están corriendo
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Error: Los contenedores deben estar corriendo para exportar"
    echo "Ejecuta: docker-compose up -d"
    exit 1
fi

# Obtener nombre del contenedor de la app
CONTAINER_NAME=$(docker-compose ps -q app)
if [ -z "$CONTAINER_NAME" ]; then
    echo "❌ Error: No se encontró el contenedor de la aplicación"
    exit 1
fi

# Obtener información del proyecto
PROJECT_NAME=${COMPOSE_PROJECT_NAME:-template-toba}
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
IMAGE_NAME="${PROJECT_NAME}-configured:${TIMESTAMP}"
LATEST_TAG="${PROJECT_NAME}-configured:latest"

echo "📦 Creando imagen desde contenedor activo..."
docker commit $CONTAINER_NAME $IMAGE_NAME

echo "🏷️  Creando tag 'latest'..."
docker tag $IMAGE_NAME $LATEST_TAG

echo "✅ Imagen creada exitosamente:"
echo "   - $IMAGE_NAME"
echo "   - $LATEST_TAG"

echo ""
echo "📤 Para subir a Docker Registry:"
echo "   docker tag $LATEST_TAG tu-registro/$LATEST_TAG"
echo "   docker push tu-registro/$LATEST_TAG"

echo ""
echo "💾 Para exportar a archivo:"
echo "   docker save -o ${PROJECT_NAME}-configured.tar $LATEST_TAG"