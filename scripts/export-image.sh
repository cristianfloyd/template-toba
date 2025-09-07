#!/bin/bash

# Script para exportar la imagen de desarrollo Toba configurada
# Este script crea una imagen Docker con toda la aplicación Toba instalada

set -e

echo " Exportando imagen de desarrollo Toba..."

# Usar docker-compose.build.yml para crear imagen distribuible
BUILD_COMPOSE="docker-compose.build.yml"

echo "🔨 Construyendo contenedor para distribución..."
docker-compose -f $BUILD_COMPOSE down 2>/dev/null || true
docker-compose -f $BUILD_COMPOSE up -d --build

# Esperar a que el contenedor esté listo
echo " Esperando que el contenedor inicialice..."
sleep 15

# Verificar que el contenedor está corriendo
if ! docker-compose -f $BUILD_COMPOSE ps | grep -q "Up"; then
    echo " Error: Los contenedores de build no están corriendo"
    echo "Verifica los logs con: docker-compose -f $BUILD_COMPOSE logs"
    exit 1
fi

# Obtener nombre del contenedor de la app
CONTAINER_NAME=$(docker-compose -f $BUILD_COMPOSE ps -q app)
if [ -z "$CONTAINER_NAME" ]; then
    echo " Error: No se encontró el contenedor de la aplicación"
    exit 1
fi

# Obtener información del proyecto
PROJECT_NAME=${COMPOSE_PROJECT_NAME:-template-toba}
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
IMAGE_NAME="${PROJECT_NAME}-configured:${TIMESTAMP}"
LATEST_TAG="${PROJECT_NAME}-configured:latest"

# Verificar que el proyecto uba_mg esté presente en el contenedor
echo "🔍 Verificando proyecto uba_mg en el contenedor..."
if ! docker exec $CONTAINER_NAME ls -la /usr/local/app/toba_framework/proyectos/uba_mg/ | grep -q "php\|metadatos\|www"; then
    echo "  El proyecto uba_mg parece estar vacío en el contenedor"
    echo "  Asegúrate de que el contenedor tenga el proyecto completo antes de exportar"
    echo "  El directorio puede estar siendo ocultado por un volumen montado"
    
    read -p "¿Continuar de todas formas? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo " Exportación cancelada"
        exit 1
    fi
fi

echo "📦 Creando imagen desde contenedor activo..."
docker commit $CONTAINER_NAME $IMAGE_NAME

echo "🏷️  Creando tag 'latest'..."
docker tag $IMAGE_NAME $LATEST_TAG

echo " Imagen creada exitosamente:"
echo "   - $IMAGE_NAME"
echo "   - $LATEST_TAG"

echo ""
echo " Para subir a Docker Registry:"
echo "   docker tag $LATEST_TAG tu-registro/$LATEST_TAG"
echo "   docker push tu-registro/$LATEST_TAG"

echo ""
echo " Para exportar a archivo:"
echo "   docker save -o ${PROJECT_NAME}-configured.tar $LATEST_TAG"

echo ""
echo " Limpiando contenedores de build..."
docker-compose -f $BUILD_COMPOSE down