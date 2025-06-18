# 🚀 SIU Toba Docker Template

Template completo para la instalación y configuración de **SIU Toba 3.4.8** utilizando Docker y Docker Compose. Esta configuración está optimizada para desarrollo local y puede adaptarse fácilmente para producción.

## 📋 Características

- 🐳 **Docker Multi-stage** con Alpine Linux 3.21
- 🔒 **Usuario no privilegiado** (`siu:www-data`) para mayor seguridad
- 🌐 **Apache 2.4** configurado en puerto 8080
- 🐘 **PostgreSQL 16** con persistencia de datos
- 🚀 **PHP 8.2** con todas las extensiones necesarias
- 📦 **Composer** y **Yarn** preinstalados
- ⚙️ **Configuración automática** del entorno TOBA
- 📚 **Documentación incluida**

## 🛠️ Tecnologías Incluidas

| Tecnología | Versión | Descripción |
|------------|---------|-------------|
| **Alpine Linux** | 3.21 | Sistema base ligero |
| **PHP** | 8.2 | Con extensiones: pdo_pgsql, gd, curl, xml, etc. |
| **Apache** | 2.4 | Servidor web configurado |
| **PostgreSQL** | 16-alpine | Base de datos |
| **Composer** | Latest | Gestor de dependencias PHP |
| **Node.js & Yarn** | Latest | Para assets frontend |

## 📁 Estructura del Proyecto

```
siu-toba-docker-template/
├── 📄 README.md                                    # Este archivo
├── 🐳 Dockerfile                                   # Configuración Docker multi-stage
├── 🐙 docker-compose.yml                          # Orquestación de servicios
├── 📚 01-Instalación de SIU Toba con Docker.md    # Guía completa de instalación
├── ⚙️ 02-Configuraciones avanzadas del entorno docker.md
└── 📁 common/                                      # Configuraciones del contenedor
    ├── 🌐 apache/                                  # Configuración Apache
    ├── 🐘 php/                                     # Configuración PHP
    ├── 🔧 siu-entrypoint.d/                       # Scripts de inicialización
    └── 📜 entrypoint.sh                           # Script de entrada
```

## 🚀 Inicio Rápido

### Prerrequisitos

- [Docker](https://docs.docker.com/get-docker/) >= 20.0
- [Docker Compose](https://docs.docker.com/compose/install/) >= 2.0
- [Git](https://git-scm.com/) (opcional)

### 1. Clonar el repositorio

```bash
git clone <tu-repositorio>
cd template-toba
```

### 2. Construir y ejecutar

```bash
# Construir y levantar todos los servicios
docker-compose up -d --build

# Verificar que estén funcionando
docker-compose ps
```

### 3. Verificar instalación

```bash
# Verificar logs del servicio web
docker-compose logs app

# Probar conectividad
curl -I http://localhost:8080
```

## 🔧 Configuración

### Servicios Docker

| Servicio | Puerto | Descripción | Credenciales |
|----------|--------|-------------|--------------|
| **app** | 8080 | Aplicación TOBA + Apache | - |
| **db** | 7432 | PostgreSQL | `postgres/postgres` |

### Variables de Entorno Principales

```bash
# Base de datos
TOBA_BASE_HOST=db
TOBA_BASE_NOMBRE=toba_3_4
TOBA_BASE_PASS=postgres

# Proyecto TOBA
TOBA_PROYECTO=desarrollo
TOBA_INSTANCIA=desarrollo
TOBA_PASS=toba

# Configuración web
DOCKER_WEB_PORT=8080
TZ=America/Argentina/Buenos_Aires
```

## 📖 Documentación Detallada

Para una guía paso a paso completa, consulta:

- 📘 **[Instalación de SIU Toba con Docker](./01-Instalación%20de%20SIU%20Toba%20con%20Docker.md)**
  - Configuración completa del entorno
  - Descarga del framework TOBA
  - Instalación y configuración del proyecto

- ⚙️ **[Configuraciones avanzadas del entorno docker](./02-Configuraciones%20avanzadas%20del%20entorno%20docker.md)**
  - Optimizaciones de rendimiento
  - Configuraciones de seguridad
  - Personalización del entorno

## 🗄️ Gestión de la Base de Datos

### Conexión a PostgreSQL

```bash
# Desde el host
psql -h localhost -p 7432 -U postgres -d toba_3_4

# Desde el contenedor
docker-compose exec db psql -U postgres -d toba_3_4
```

### Backup y Restore

```bash
# Backup
docker-compose exec db pg_dump -U postgres toba_3_4 > backup_toba.sql

# Restore
docker-compose exec -T db psql -U postgres toba_3_4 < backup_toba.sql
```

## 🛠️ Comandos Útiles

### Gestión de contenedores

```bash
# Ver logs en tiempo real
docker-compose logs -f app

# Acceder al contenedor de la aplicación
docker-compose exec app bash

# Reiniciar servicios
docker-compose restart

# Parar todos los servicios
docker-compose down

# Parar y eliminar volúmenes (⚠️ se perderán los datos)
docker-compose down -v
```

### Desarrollo

```bash
# Acceder al contenedor como usuario siu
docker-compose exec app bash

# Instalar dependencias PHP
composer install

# Instalar dependencias JS
yarn install

# Ver procesos del contenedor
docker-compose exec app ps aux
```

## 🚨 Solución de Problemas

### Problema: Puerto 8080 en uso
```bash
# Cambiar puerto en docker-compose.yml
ports:
  - "8081:8080"  # Usar puerto 8081 en lugar de 8080
```

### Problema: Permisos de archivos
```bash
# El contenedor usa usuario 'siu' (UID 222)
# Si necesitas cambiar permisos desde el host:
sudo chown -R 222:33 ./carpeta-problema
```

### Problema: Base de datos no conecta
```bash
# Verificar que PostgreSQL esté funcionando
docker-compose exec db pg_isready -U postgres

# Ver logs de la base de datos
docker-compose logs db
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crea un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🆘 Soporte

- 📧 **Issues**: [Reportar un problema](../../issues)
- 📖 **Wiki**: [Documentación adicional](../../wiki)
- 💬 **Discusiones**: [Foro de la comunidad](../../discussions)

## 🔗 Enlaces Útiles

- [SIU Toba Framework](https://github.com/SIU-Toba/framework) - Repositorio oficial
- [SIU Toba Documentación](https://documentacion.siu.edu.ar/toba/) - Documentación oficial
- [Docker Documentation](https://docs.docker.com/) - Documentación Docker
- [PostgreSQL Documentation](https://www.postgresql.org/docs/) - Documentación PostgreSQL

---

**⭐ Si este proyecto te ayudó, ¡no olvides darle una estrella!**

---

*Desarrollado con ❤️ para la comunidad SIU Toba* 
