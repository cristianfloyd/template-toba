# Guía de Distribución - Template Toba Configurado

Esta guía explica cómo distribuir un entorno de desarrollo Toba completamente configurado usando Docker Registry.

## Problema que Resuelve

Permite a otros desarrolladores obtener un entorno Toba **completamente funcional** sin:

- Construir la imagen desde cero
- Instalar manualmente el framework Toba
- Configurar base de datos y dependencias
- Perder tiempo en setup inicial

## Componentes de la Distribución

### 1. Imagen de Aplicación

- **Contiene**: Sistema base, Apache, PHP, framework Toba instalado, código de aplicación
- **No contiene**: Datos de base de datos, archivos dinámicos

### 2. Backup de Base de Datos

- **Contiene**: Esquemas, datos, usuarios, configuraciones
- **Formato**: SQL comprimido para fácil restauración

## Proceso de Distribución

### Paso 1: Preparar la Exportación

```bash
# Asegurar que todo esté funcionando
docker-compose up -d

# Exportar imagen configurada
./scripts/export-image.sh

# Crear backup de base de datos
./scripts/backup-database.sh
```

### Paso 2: Subir al Registry

```bash
# Tagear para tu registry (ejemplo Docker Hub)
docker tag template-toba-configured:latest tu-usuario/toba-dev:latest

# Subir imagen
docker push tu-usuario/toba-dev:latest
```

### Paso 3: Preparar Archivos de Distribución

```bash
# Crear paquete de distribución
mkdir toba-distribution
cp docker-compose.distribution.yml toba-distribution/docker-compose.yml
cp -r backups/ toba-distribution/
cp docs/DISTRIBUCION.md toba-distribution/README.md
```

## Uso por Otros Desarrolladores

### Requisitos Previos

- Docker y Docker Compose instalados
- Puertos 8080 y 7432 disponibles

### Instalación

```bash
# 1. Obtener archivos de distribución
# (desde repositorio o paquete distribuido)

# 2. Actualizar docker-compose.yml con la imagen correcta
# Cambiar: image: tu-usuario/toba-dev:latest

# 3. Iniciar servicios
docker-compose up -d

# 4. Verificar funcionamiento
curl http://localhost:8080
```

### Restauración Automática de DB

Si colocas los backups en `backups/database/`, PostgreSQL los ejecutará automáticamente al iniciarse por primera vez.

## 🔧 Mantenimiento y Actualizaciones

### Actualizar Imagen

```bash
# En el entorno original
./scripts/export-image.sh
docker push tu-usuario/toba-dev:latest

# Los desarrolladores actualizan con:
docker-compose pull
docker-compose up -d
```

### Sincronizar Base de Datos

```bash
# Crear nuevo backup
./scripts/backup-database.sh

# Distribuir archivo de backup actualizado
# Los desarrolladores restauran con:
gunzip -c backup-file.sql.gz | docker-compose exec -T db psql -U postgres -d toba_3_4
```

## Ventajas de este Enfoque

1. **Setup instantáneo**: De 2-3 horas a 5 minutos
2. **Consistencia**: Todos usan la misma configuración
3. **Versionado**: Diferentes versiones de la imagen
4. **Rollback fácil**: Volver a versiones anteriores
5. **CI/CD friendly**: Integración con pipelines

## Consideraciones de Seguridad

- **No incluir credenciales reales** en imágenes públicas
- Usar variables de entorno para configuraciones sensibles
- Registries privados para código propietario
- Revisar que no se expongan secrets en backups

## Estructura Final de Distribución

```bash
toba-distribution/
├── docker-compose.yml          # Configuración para usar imagen pre-construida
├── backups/
│   └── database/
│       ├── toba-db-backup-*.sql.gz
│       └── toba-roles-*.sql
├── README.md                   # Esta guía
└── .env.example               # Variables de entorno de ejemplo
```

## Resolución de Problemas

### Error: Puerto en uso

```bash
# Cambiar puertos en docker-compose.yml
ports:
  - "8081:80"  # En lugar de 8080
  - "7433:5432" # En lugar de 7432
```

### Error: Permisos de archivos

```bash
# Ajustar UID/GID en docker-compose.yml
user: "1000:1000"
```

### Base de datos vacía

```bash
# Restaurar manualmente
gunzip -c backups/database/toba-db-backup-*.sql.gz | docker-compose exec -T db psql -U postgres -d toba_3_4
```
