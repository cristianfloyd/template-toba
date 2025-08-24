#!/bin/bash

# Script para extraer el código del proyecto uba_mg desde el contenedor
# Permite a los desarrolladores obtener el código fuente para editar

set -e

echo "📁 Extrayendo código del proyecto uba_mg..."

# Verificar que los contenedores están corriendo
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Error: Los contenedores deben estar corriendo para extraer"
    echo "Ejecuta: docker-compose up -d"
    exit 1
fi

# Crear directorio local para el proyecto
PROJECT_DIR="./uba_mg"
if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️  El directorio $PROJECT_DIR ya existe"
    read -p "¿Deseas sobrescribirlo? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Operación cancelada"
        exit 1
    fi
    echo "🗑️  Eliminando directorio existente..."
    rm -rf "$PROJECT_DIR"
fi

echo "📋 Copiando código del proyecto desde el contenedor..."
docker-compose exec app cp -r /usr/local/app/toba_framework/proyectos/uba_mg /tmp/uba_mg_copy
docker-compose cp app:/tmp/uba_mg_copy ./uba_mg

# Ajustar permisos para el usuario local
echo "🔧 Ajustando permisos de archivos..."
sudo chown -R $USER:$USER ./uba_mg
chmod -R 755 ./uba_mg

echo "✅ Código extraído exitosamente en: $PROJECT_DIR"
echo ""
echo "🚀 Próximos pasos:"
echo "1. Abrir VS Code: code ./uba_mg"
echo "2. Usar docker-compose.distribution.yml para desarrollo:"
echo "   docker-compose -f docker-compose.distribution.yml up -d"
echo ""
echo "⚡ Los cambios en ./uba_mg se reflejarán automáticamente en la aplicación"