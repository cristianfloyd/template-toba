#!/bin/bash

# Script conveniente para instalar assets de Bootstrap en Toba Framework
# Uso: ./docker/scripts/install-bootstrap.sh

echo "🚀 Ejecutando instalación de assets de Bootstrap en el contenedor..."

cd "$(dirname "$0")/../.."

# Verificar que docker-compose está disponible
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: docker-compose no está disponible"
    exit 1
fi

# Verificar que el contenedor está corriendo
if ! docker-compose ps app | grep -q "Up"; then
    echo "⚠️  El contenedor no está corriendo. Iniciando..."
    docker-compose up -d
fi

# Ejecutar el script de corrección
echo "🔧 Ejecutando corrección de assets..."
docker-compose exec app /usr/local/app/docker/scripts/fix-bootstrap-assets.sh

echo "✅ Instalación completada!"