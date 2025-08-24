#!/bin/bash

# Script para hacer backup completo de la base de datos Toba
# Incluye esquemas, datos, usuarios y configuraciones

set -e

echo "🗃️  Creando backup de la base de datos Toba..."

# Verificar que la base de datos está corriendo
if ! docker-compose ps db | grep -q "Up"; then
    echo "❌ Error: El contenedor de base de datos debe estar corriendo"
    echo "Ejecuta: docker-compose up -d db"
    exit 1
fi

# Configuración
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="./backups/database"
BACKUP_FILE="toba-db-backup-${TIMESTAMP}.sql"
SCHEMA_FILE="toba-db-schema-${TIMESTAMP}.sql"

# Crear directorio de backups
mkdir -p $BACKUP_DIR

echo "📊 Creando backup completo (datos + esquema)..."
docker-compose exec -T db pg_dump -U postgres -d toba_3_4 --verbose > "$BACKUP_DIR/$BACKUP_FILE"

echo "🏗️  Creando backup solo esquema (sin datos)..."
docker-compose exec -T db pg_dump -U postgres -d toba_3_4 --schema-only > "$BACKUP_DIR/$SCHEMA_FILE"

echo "📋 Exportando información de usuarios y roles..."
docker-compose exec -T db pg_dumpall -U postgres --roles-only > "$BACKUP_DIR/toba-roles-${TIMESTAMP}.sql"

# Comprimir backups
echo "🗜️  Comprimiendo backups..."
cd $BACKUP_DIR
gzip $BACKUP_FILE
gzip $SCHEMA_FILE

echo "✅ Backup completado:"
echo "   - Datos completos: $BACKUP_DIR/${BACKUP_FILE}.gz"
echo "   - Solo esquema: $BACKUP_DIR/${SCHEMA_FILE}.gz" 
echo "   - Roles/usuarios: $BACKUP_DIR/toba-roles-${TIMESTAMP}.sql"

echo ""
echo "🔄 Para restaurar en otro contenedor:"
echo "   # Copiar roles/usuarios:"
echo "   docker-compose exec -T db psql -U postgres < backups/database/toba-roles-${TIMESTAMP}.sql"
echo "   # Restaurar base de datos:"
echo "   gunzip -c $BACKUP_DIR/${BACKUP_FILE}.gz | docker-compose exec -T db psql -U postgres -d toba_3_4"