## 7. Configuraciones Avanzadas del Entorno Docker

###  TODO: landing page con las variables de enotrno y verificaciones php, mas links de acceso

### 7.1 Variables de Entorno Explicadas

#### Variables del Contenedor de Aplicación:
- `TZ=America/Argentina/Buenos_Aires` - Zona horaria del contenedor
- `DOCKER_NAME=web-toba` - Nombre identificador interno del contenedor web
- `DOCKER_WEB_PORT=8080` - Puerto interno del servidor web
- `TOBA_PASS=toba` - Contraseña por defecto para usuarios de Toba
- `TOBA_BASE_PASS=postgres` - Contraseña de la base de datos PostgreSQL
- `TOBA_INSTALACION_DIR=/var/local/docker-data/framework-instalacion` - Directorio de instalación del framework
- `TOBA_BASE_HOST=db` - Host de la base de datos (nombre del servicio)
- `TOBA_BASE_NOMBRE=toba_desarrollo` - Nombre de la base de datos
- `TOBA_PROYECTO_INSTALAR=True` - Instala automáticamente los proyectos base
- `TOBA_INSTALAR_REFERENCIA=True` - Instala datos de referencia del sistema
- `TOBA_INSTALAR_USUARIOS=True` - Crea usuarios predeterminados del sistema
- `TOBA_REDIRECCIONAR_LOGS=1` - Redirige logs a stdout/stderr para Docker

