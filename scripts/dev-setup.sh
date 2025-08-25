#!/bin/bash

# Script completo de setup para desarrolladores
# Configura el entorno de desarrollo con imagen pre-construida + código local

set -e

echo "🚀 Configurando entorno de desarrollo Toba..."

# Verificar requisitos
echo "🔍 Verificando requisitos..."
command -v docker >/dev/null 2>&1 || { echo "❌ Docker no instalado"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "❌ Docker Compose no instalado"; exit 1; }

# Crear directorios necesarios con permisos correctos
echo "📁 Creando directorios necesarios..."
mkdir -p logs uploads
chmod 755 logs uploads
chown 1000:82 logs uploads 2>/dev/null || true

# Verificar puertos disponibles
if netstat -tuln | grep -q ":8080 "; then
    echo "⚠️  Puerto 8080 en uso. Cambiando a 8081..."
    sed -i 's/"8080:80"/"8081:80"/g' docker-compose.distribution.yml
fi

if netstat -tuln | grep -q ":7432 "; then
    echo "⚠️  Puerto 7432 en uso. Cambiando a 7433..."
    sed -i 's/"7432:5432"/"7433:5432"/g' docker-compose.distribution.yml
fi

# Obtener imagen actualizada
echo "📥 Descargando imagen más reciente..."
docker-compose -f docker-compose.distribution.yml pull app

# Iniciar servicios en background
echo "🐳 Iniciando contenedores..."
docker-compose -f docker-compose.distribution.yml up -d

# Esperar a que los servicios estén listos
echo "⏳ Esperando que los servicios inicien..."
sleep 10

# Verificar que la app esté funcionando
echo "🔍 Verificando estado de la aplicación..."
if curl -f -s http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ Aplicación accesible en http://localhost:8080"
elif curl -f -s http://localhost:8081 >/dev/null 2>&1; then
    echo "✅ Aplicación accesible en http://localhost:8081"
else
    echo "⚠️  La aplicación puede tardar unos segundos más en estar lista"
fi

# Obtener código del proyecto para edición
if [ ! -d "./uba_mg" ] || [ -z "$(ls -A ./uba_mg)" ]; then
    echo "📁 Directorio uba_mg no encontrado o vacío"
    echo ""
    echo "💡 Para obtener el código del proyecto uba_mg:"
    echo "   1. Clonar desde GitLab UBA (requiere VPN UBA):"
    echo "      git clone https://gitlab.rec.uba.ar/grupo/uba_mg.git ./uba_mg"
    echo ""
    echo "   2. Copiar desde directorio local:"
    echo "      cp -r /ruta/local/uba_mg ./uba_mg"
    echo ""
    echo "   3. Extraer desde un backup/zip:"
    echo "      unzip uba_mg.zip && mv uba_mg-backup ./uba_mg"
    echo ""
    echo "ℹ️  La configuración de Toba ya está incluida en la imagen Docker"
    echo ""
    
    # Crear directorio vacío
    mkdir -p ./uba_mg
    
    echo "⏸️  El setup continuará cuando tengas el código en ./uba_mg/"
    echo "   Verifica que contenga: php/, www/, metadatos/, etc."
    echo ""
    read -p "Presiona Enter después de agregar el código del proyecto..."
    
    # Verificar que se agregó contenido
    if [ -z "$(ls -A ./uba_mg)" ]; then
        echo "⚠️  El directorio ./uba_mg sigue vacío"
        echo "   El contenedor funcionará pero sin código para editar"
    else
        echo "✅ Código del proyecto detectado en ./uba_mg"
    fi
else
    echo "✅ Código del proyecto ya existe en ./uba_mg"
fi

# Verificar si la base de datos está inicializada (verificando tabla principal de Toba)
echo "🗃️  Verificando estado de la base de datos..."
DB_INITIALIZED=$(docker-compose -f docker-compose.distribution.yml exec -T db psql -U postgres -d toba_3_4 -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'apex_proyecto';" 2>/dev/null | grep -o '[0-9]\+' || echo "0")

if [ "$DB_INITIALIZED" = "0" ]; then
    echo "🔧 Base de datos vacía, inicializando con datos del proyecto..."
    
    # Buscar backup seed en el repositorio
    SEED_BACKUP=$(find ./backups/database/ -name "*seed*.sql.gz" 2>/dev/null | head -1)
    SEED_ROLES=$(find ./backups/database/ -name "*seed*.sql" -o -name "*roles*.sql" 2>/dev/null | head -1)
    
    if [ -n "$SEED_BACKUP" ]; then
        echo "📥 Restaurando roles y usuarios..."
        if [ -n "$SEED_ROLES" ]; then
            docker-compose -f docker-compose.distribution.yml exec -T db psql -U postgres < "$SEED_ROLES" 2>/dev/null || true
        fi
        
        echo "📥 Restaurando base de datos completa desde: $SEED_BACKUP"
        gunzip -c "$SEED_BACKUP" | docker-compose -f docker-compose.distribution.yml exec -T db psql -U postgres -d toba_3_4
        echo "✅ Base de datos inicializada correctamente"
        
        # Verificar que la inicialización fue exitosa
        DB_CHECK=$(docker-compose -f docker-compose.distribution.yml exec -T db psql -U postgres -d toba_3_4 -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'apex_proyecto';" 2>/dev/null | grep -o '[0-9]\+' || echo "0")
        if [ "$DB_CHECK" = "1" ]; then
            echo "✅ Verificación exitosa: Tabla apex_proyecto encontrada"
        else
            echo "⚠️  Advertencia: La restauración puede no haber sido completa"
        fi
    else
        echo "⚠️  No se encontró backup seed. La base de datos estará vacía."
        echo "   Para inicializar manualmente:"
        echo "   1. Ejecuta el contenedor original: docker-compose up -d"
        echo "   2. Crea backup: ./scripts/backup-database.sh"
        echo "   3. Copia el backup como seed a ./backups/database/"
    fi
else
    echo "✅ Base de datos ya inicializada (tabla apex_proyecto encontrada)"
fi

# Mostrar información final
echo ""
echo "🎉 ¡Entorno de desarrollo configurado!"
echo ""
echo "📂 Estructura del proyecto:"
echo "   ├── uba_mg/              # Código PHP del proyecto (editable en VS Code)"
echo "   ├── docker-compose.distribution.yml"
echo "   └── backups/            # Backups de base de datos"
echo ""
echo "🛠️  Comandos útiles:"
echo "   code ./uba_mg           # Abrir proyecto en VS Code"
echo "   docker-compose -f docker-compose.distribution.yml logs -f app"
echo "   docker-compose -f docker-compose.distribution.yml exec app bash"
echo ""
echo "🌐 URLs:"
echo "   Aplicación: http://localhost:8080 (o 8081)"
echo "   PostgreSQL: localhost:7432 (o 7433)"