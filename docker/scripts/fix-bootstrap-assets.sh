#!/bin/bash

# Script para corregir la instalación de assets de Bootstrap en Toba Framework
# Soluciona el problema de paths incorrectos en el script original

set -e

echo "🔧 Iniciando corrección de assets de Bootstrap..."

# Definir rutas
TOBA_ROOT="/usr/local/app/toba_framework"
BOOTSTRAP_VENDOR="$TOBA_ROOT/vendor/siu/manejador-salida-bootstrap"
ASSETS_DEST="$TOBA_ROOT/www/siu/manejador_salida_bootstrap"

# Verificar que existe el directorio vendor
if [ ! -d "$BOOTSTRAP_VENDOR" ]; then
    echo "❌ Error: No se encuentra el directorio $BOOTSTRAP_VENDOR"
    exit 1
fi

# Crear directorios de destino
echo "📁 Creando directorios de destino..."
mkdir -p "$ASSETS_DEST"/{js/{bootstrap,respond.js,html5shiv},css/fontawesome,img}

# Cambiar al directorio del manejador Bootstrap
cd "$BOOTSTRAP_VENDOR"

# Instalar dependencias de Node.js si no existen
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias de Node.js..."
    yarn add font-awesome@4.7.0 respond.js@1.4.2 html5shiv@3.7.3 --modules-folder node_modules/
    yarn add bootstrap@3.3.7 --no-dev --modules-folder node_modules/
fi

echo "📋 Copiando assets..."

# Copiar assets propios del manejador
if [ -d "src/SIU/ManejadorSalidaBootstrap/Componentes/assets" ]; then
    echo "  → Copiando assets del manejador Bootstrap..."
    cp -r src/SIU/ManejadorSalidaBootstrap/Componentes/assets/* "$ASSETS_DEST/"
fi

# Copiar Bootstrap dist
if [ -d "node_modules/bootstrap/dist" ]; then
    echo "  → Copiando Bootstrap..."
    cp -r node_modules/bootstrap/dist/* "$ASSETS_DEST/js/bootstrap/"
else
    echo "⚠️  Bootstrap dist no encontrado"
fi

# Copiar respond.js
if [ -d "node_modules/respond.js/dest" ]; then
    echo "  → Copiando respond.js..."
    cp -r node_modules/respond.js/dest/* "$ASSETS_DEST/js/respond.js/"
else
    echo "⚠️  respond.js no encontrado"
fi

# Copiar html5shiv
if [ -d "node_modules/html5shiv/dist" ]; then
    echo "  → Copiando html5shiv..."
    cp -r node_modules/html5shiv/dist/* "$ASSETS_DEST/js/html5shiv/"
else
    echo "⚠️  html5shiv no encontrado"
fi

# Copiar FontAwesome
if [ -d "node_modules/font-awesome" ]; then
    echo "  → Copiando FontAwesome..."
    cp -r node_modules/font-awesome/* "$ASSETS_DEST/css/fontawesome/"
else
    echo "⚠️  FontAwesome no encontrado"
fi

# Verificar que los archivos se copiaron
echo "✅ Verificando instalación..."
if [ -f "$ASSETS_DEST/js/bootstrap/js/bootstrap.min.js" ]; then
    echo "  ✅ Bootstrap JS: OK"
else
    echo "  ❌ Bootstrap JS: FALTA"
fi

if [ -f "$ASSETS_DEST/css/fontawesome/css/font-awesome.min.css" ]; then
    echo "  ✅ FontAwesome CSS: OK"
else
    echo "  ❌ FontAwesome CSS: FALTA"
fi

echo "🎉 Assets de Bootstrap instalados correctamente!"
echo "📍 Ubicación: $ASSETS_DEST"