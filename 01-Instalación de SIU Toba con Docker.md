# Instalación de SIU Toba 3.4.8 con Docker

## Requisitos Previos

- Docker
- Docker Compose
- Git

## Estructura de Archivos

```bash
toba-desarrollo-umg/
├── Dockerfile
├── docker-compose.yml
├── common/
│   ├── apache/
│   │   ├── global-settings.conf
│   │   └── siu.conf
│   ├── php/
│   ├── siu-entrypoint.d/
│   └── entrypoint.sh
├── instalacion/
└── toba_framework/ (generado durante la instalación)
```

## Pasos de Instalación

### 1. Configuración del Dockerfile

El Dockerfile está configurado con tres etapas:

- `cli`: Base con PHP 8.2 y dependencias básicas
- `web`: Agrega Apache2 y configuraciones web
- `rootless`: Configura usuario no privilegiado `siu` (recomendado para producción)

**Tecnologías incluidas:**
- Alpine Linux 3.21
- PHP 8.2 con extensiones necesarias para TOBA
- Apache 2.4 configurado en puerto 8080
- PostgreSQL client
- Composer y Yarn
- Node.js y npm

### 2. Configuración del docker-compose.yml

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: rootless  # Usuario no privilegiado
    container_name: toba-app
    restart: unless-stopped
    working_dir: /usr/local/app
    volumes:
      - ./:/usr/local/app
      - ./instalacion:/var/local/docker-data/framework-instalacion
    environment:
      - TZ=America/Argentina/Buenos_Aires
      - DOCKER_NAME=web-toba
      - DOCKER_WEB_PORT=8080
      - TOBA_PASS=toba
      - TOBA_BASE_PASS=postgres
      - TOBA_INSTALACION_DIR=/var/local/docker-data/framework-instalacion
      - TOBA_BASE_HOST=db
      - TOBA_BASE_NOMBRE=toba_3_4  # Nombre correcto de la BD
      - TOBA_PROYECTO_INSTALAR=True
      - TOBA_INSTALAR_REFERENCIA=True
      - TOBA_INSTALAR_USUARIOS=True
      - TOBA_REDIRECCIONAR_LOGS=1
      - TOBA_INSTANCIA=desarrollo
      - TOBA_PROYECTO=desarrollo
      - TOBA_PROYECTO_DIR=/usr/local/app
      - TOBA_PROYECTO_ALIAS=/toba
    ports:
      - "8080:8080"
    networks:
      - toba-network

  db:
    image: postgres:16-alpine
    ports:
    - "7432:5432"
    container_name: toba-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: toba_3_4  # Nombre correcto de la BD
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      TZ: America/Argentina/Buenos_Aires
    volumes:
      - dbdata:/var/lib/postgresql/data
    networks:
      - toba-network

networks:
  toba-network:
    driver: bridge

volumes:
  dbdata:
```

### 3. Construcción de Contenedores

```bash
# Construir y levantar los contenedores
docker-compose up -d --build

# Verificar que estén funcionando
docker-compose ps
```

### 4. Verificar Apache y PHP

```bash
# Verificar logs de Apache
docker-compose logs app

# Verificar procesos dentro del contenedor
docker-compose exec app ps aux | grep httpd

# Probar conectividad HTTP
curl -I http://localhost:8080
```

### 5. Descarga del Framework TOBA

Existen **dos opciones** para descargar el framework TOBA desde el [repositorio oficial](https://github.com/SIU-Toba/framework):

#### **Opción 1: Git Clone (Recomendado para desarrollo)**

```bash
# Acceder al contenedor
docker-compose exec app bash

# Clonar el repositorio completo
cd /usr/local/app
git clone https://github.com/SIU-Toba/framework.git toba_framework

# Cambiar a la rama o versión deseada (opcional)
cd toba_framework
git checkout v3.4.8  # Para versión específica
# o
git checkout develop  # Para la rama de desarrollo
```

#### **Opción 2: Descarga ZIP (Más rápido)**

```bash
# Acceder al contenedor
docker-compose exec app bash

# Descargar versión específica (v3.4.8 - Latest)
cd /usr/local/app
wget https://github.com/SIU-Toba/framework/archive/refs/tags/v3.4.8.tar.gz
tar -xzf v3.4.8.tar.gz
mv framework-3.4.8 toba_framework
rm v3.4.8.tar.gz

# O descargar la rama develop (versión de desarrollo)
wget https://github.com/SIU-Toba/framework/archive/refs/heads/develop.zip
unzip develop.zip
mv framework-develop toba_framework
rm develop.zip
```

#### **Verificar descarga**

```bash
# Verificar que el framework se descargó correctamente
ls -la toba_framework/
# Deberías ver: bin/, php/, proyectos/, www/, composer.json, etc.

# Verificar versión
cat toba_framework/VERSION
```

**💡 Notas importantes:**

- **Permisos automáticos:** Como usamos el target `rootless` en Docker, el usuario `siu:www-data` crea automáticamente los directorios con los permisos correctos. **No es necesario ejecutar `chown`** manualmente.

- **Versiones disponibles:** El repositorio tiene [81 releases](https://github.com/SIU-Toba/framework) disponibles. La versión **v3.4.8** es la más reciente (enero 2025).

- **Opción recomendada:** Para desarrollo activo, usar `git clone` permite actualizaciones fáciles con `git pull`. Para instalaciones de producción, usar descarga ZIP es más rápida.

#### **Ventajas de cada opción:**

| Opción | Ventajas | Desventajas |
|--------|----------|-------------|
| **Git Clone** | - Actualizaciones fáciles con `git pull`<br>- Control de versiones completo<br>- Cambio entre ramas sencillo | - Descarga más lenta<br>- Requiere Git en el contenedor |
| **ZIP Download** | - Descarga más rápida<br>- Menor uso de espacio<br>- No requiere conocimiento de Git | - Sin historial de versiones<br>- Actualizaciones manuales |

**🎯 Para este tutorial, cualquiera de las dos opciones funciona perfectamente.**

### 6. Instalación de Dependencias

```bash
# Dentro del directorio toba_framework
cd toba_framework

# Instalar dependencias de PHP con Composer
composer install
```

**Resultado esperado:**
- 81 paquetes instalados correctamente
- Configuración automática de yarn y assets de JavaScript
- Instalación automatizada de TOBA 3.4.8

### 7. Instalación y Configuración de TOBA

Durante el `composer install`, TOBA se instala automáticamente con:

```bash
php bin/toba instalacion instalar
```

**Configuración utilizada:**
- Alias del núcleo: `toba`
- Número de desarrollador: `300`
- Instalación de producción: `No`
- Nombre de la instalación: `desarrollo`
- PostgreSQL Host: `db`
- PostgreSQL Puerto: `5432`
- PostgreSQL Usuario: `postgres`
- PostgreSQL Clave: `postgres`
- Base de datos: `toba_3_4`
- Schema: `desarrollo`
- Clave usuario toba: `toba`

```bash
# salir del contenedor
exit
```

### 8. Configuración Final de Apache

```bash
# Crear enlace simbólico para configuración de Apache
docker-compose exec app ln -s /var/local/docker-data/framework-instalacion/toba.conf /etc/apache2/conf.d/toba_3_4.conf

# Verificar configuración
docker-compose exec app httpd -t

# Reiniciar Apache
docker-compose restart app
```

## Verificación de Instalación Exitosa

### Verificar Logs

```bash
docker-compose logs app | tail -20
```

**Mensajes esperados en los logs:**
- `[INFO][toba] Se detecto cambio de operación. Se limpia la memoria de la operacion`
- `[DEBUG][toba_editor] INSTANCIA "desarrollo"`
- `[DEBUG][toba_editor] Parametros instancia desarrollo`
- Logs de acceso HTTP 200 exitosos
- Carga de recursos (imágenes, CSS, JS)

### Accesos Web Disponibles

Una vez completada la instalación, estarán disponibles:

- **🏠 http://localhost:8080/toba_editor/3.4** - Editor principal de TOBA
- **📚 http://localhost:8080/toba_referencia/3.4** - Ejemplos y documentación
- **👥 http://localhost:8080/toba_usuarios/3.4** - Gestión de usuarios

### Credenciales de Acceso

- **Usuario:** `toba`
- **Contraseña:** `toba`

## Proyectos Instalados

La instalación incluye tres proyectos:

1. **toba_editor** - Editor y administrador del framework
2. **toba_referencia** - Ejemplos y casos de uso
3. **toba_usuarios** - Sistema de gestión de usuarios

## Comandos Útiles Post-Instalación

### Crear un Nuevo Proyecto

```bash
# Acceder al contenedor
docker-compose exec app bash

# Cargar entorno TOBA
source /var/local/docker-data/framework-instalacion/entorno_toba.env

# Crear nuevo proyecto
toba proyecto crear
```

### Backup de la Base de Datos

```bash
# Backup completo
docker-compose exec db pg_dump -U postgres toba_3_4 > backup_toba_$(date +%Y%m%d).sql

# Restaurar backup
docker-compose exec -T db psql -U postgres toba_3_4 < backup_toba.sql
```

### Monitoreo y Logs

```bash
# Ver logs en tiempo real
docker-compose logs -f app

# Ver logs de PostgreSQL
docker-compose logs db

# Verificar uso de recursos
docker-compose exec app top
```

## Configuración de Desarrollo

### Variables de Entorno Importantes

El archivo `/var/local/docker-data/framework-instalacion/entorno_toba.env` contiene:

```bash
export TOBA_INSTALACION_DIR="/var/local/docker-data/framework-instalacion"
export TOBA_DIR="/usr/local/app/toba_framework"
# ... otras variables
```

### Estructura de Directorios Final

```bash
/usr/local/app/
├── toba_framework/          # Framework TOBA descargado
│   ├── bin/                 # Scripts ejecutables
│   ├── php/                 # Código PHP del framework
│   ├── www/                 # Assets web
│   ├── proyectos/           # Proyectos instalados
│   │   ├── toba_editor/
│   │   ├── toba_referencia/
│   │   └── toba_usuarios/
│   └── vendor/              # Dependencias de Composer
└── instalacion/             # Configuraciones de instalación
```

## Troubleshooting

### Problemas Comunes

1. **Error de permisos:**
   ```bash
   docker-compose exec app chown -R siu:www-data /usr/local/app
   ```

2. **Apache no inicia:**
   ```bash
   docker-compose exec app httpd -t
   docker-compose restart app
   ```

3. **Base de datos no conecta:**
   ```bash
   docker-compose exec app php -r "
   try {
       \$pdo = new PDO('pgsql:host=db;port=5432;dbname=toba_3_4', 'postgres', 'postgres');
       echo 'Conexión exitosa\n';
   } catch (PDOException \$e) {
       echo 'Error: ' . \$e->getMessage() . '\n';
   }"
   ```

## Notas Importantes

- ✅ **Entorno de desarrollo** con usuario no privilegiado `siu`
- ✅ **Archivos editables** desde el host gracias al volumen montado
- ✅ **Base de datos persistente** en volumen Docker
- ✅ **TOBA 3.4.8** completamente funcional
- ✅ **PHP 8.2** con todas las extensiones necesarias
- 🔐 **Cambiar contraseña** del usuario `toba` en producción
- 📝 **Backup regular** de la base de datos recomendado

## Tiempo de Instalación

- **Construcción de contenedores:** ~5-10 minutos
- **Descarga de TOBA:** ~2-3 minutos  
- **Composer install:** ~5-8 minutos
- **Instalación de TOBA:** ~1-2 minutos (76.9 segundos en el ejemplo)
- **Total estimado:** ~15-25 minutos

---

**🎉 ¡Instalación exitosa! TOBA 3.4.8 está listo para desarrollo.**

