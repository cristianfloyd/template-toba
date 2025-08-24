#!/bin/bash

# Script para corregir los scripts de Bootstrap en el composer.json global del framework
# Esto hace que composer install/update ejecute automáticamente fix-bootstrap-assets.sh

set -e

TOBA_ROOT="/usr/local/app/toba_framework"
COMPOSER_JSON="$TOBA_ROOT/composer.json"

if [ ! -f "$COMPOSER_JSON" ]; then
    echo "❌ Error: composer.json del framework no encontrado en $COMPOSER_JSON"
    exit 1
fi

echo "🔧 Corrigiendo scripts de Bootstrap en el framework global..."

# Usar PHP para modificar los scripts del JSON global
export COMPOSER_JSON
php << 'EOPHP'
<?php
$composerFile = getenv('COMPOSER_JSON');
$json = json_decode(file_get_contents($composerFile), true);

// Corregir los scripts post-install-cmd
if (isset($json['scripts']['post-install-cmd'])) {
    $scripts = $json['scripts']['post-install-cmd'];
    
    // Reemplazar el comando problemático con el script corregido
    for ($i = 0; $i < count($scripts); $i++) {
        if (strpos($scripts[$i], 'composer run-script post-install-cmd -d ./vendor/siu/manejador-salida-bootstrap/') !== false) {
            $scripts[$i] = 'fix-bootstrap-assets.sh';
            echo "✅ Corregido post-install-cmd\n";
        }
    }
    $json['scripts']['post-install-cmd'] = $scripts;
}

// Corregir los scripts post-update-cmd
if (isset($json['scripts']['post-update-cmd'])) {
    $scripts = $json['scripts']['post-update-cmd'];
    
    // Reemplazar el comando problemático con el script corregido
    for ($i = 0; $i < count($scripts); $i++) {
        if (strpos($scripts[$i], 'composer run-script post-install-cmd -d ./vendor/siu/manejador-salida-bootstrap/') !== false) {
            $scripts[$i] = 'fix-bootstrap-assets.sh';
            echo "✅ Corregido post-update-cmd\n";
        }
    }
    $json['scripts']['post-update-cmd'] = $scripts;
}

// Guardar el archivo
file_put_contents($composerFile, json_encode($json, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
echo "✅ Scripts del framework corregidos\n";
EOPHP

echo "🎉 Corrección completada en el framework global"
echo "📍 Ahora composer install/update ejecutará automáticamente fix-bootstrap-assets.sh"