# Instalación de SIU Toba 3.4.8 con Docker

> **Esta guía asume que ya tienes el template clonado y los contenedores Docker creados y corriendo.**

---

## Índice

1. [Pasos de Instalación](#pasos-de-instalación)
   - [Descarga del Framework TOBA](#1-descarga-del-framework-toba)
   - [Instalación de Dependencias](#2-instalación-de-dependencias)
   - [Instalación y Configuración de TOBA](#3-instalación-y-configuración-de-toba)
   - [Configuración Final de Apache](#4-configuración-final-de-apache)
   - [Verificación de Instalación Exitosa](#5-verificación-de-instalación-exitosa)
2. [Accesos Web Disponibles](#accesos-web-disponibles)
3. [Credenciales de Acceso](#credenciales-de-acceso)
4. [Proyectos Instalados](#proyectos-instalados)
5. [Comandos Útiles Post-Instalación](#comandos-útiles-post-instalación)
6. [Configuración de Desarrollo](#configuración-de-desarrollo)
7. [Troubleshooting](#troubleshooting)
8. [Notas Importantes](#notas-importantes)
9. [Tiempo de Instalación](#tiempo-de-instalación)

---

## Pasos de Instalación

### 1. Descarga del Framework TOBA

Existen **dos opciones** para descargar el framework TOBA desde el [repositorio oficial](https://github.com/SIU-Toba/framework):

#### Opción 1: Git Clone (Recomendado para desarrollo)

```bash
docker-compose exec app bash
cd /usr/local/app
git clone https://github.com/SIU-Toba/framework.git toba_framework
cd toba_framework
git checkout v3.4.8  # O la rama deseada
```

#### Opción 2: Descarga ZIP (Más rápido)

```bash
docker-compose exec app bash
cd /usr/local/app
wget https://github.com/SIU-Toba/framework/archive/refs/tags/v3.4.8.tar.gz
tar -xzf v3.4.8.tar.gz
mv framework-3.4.8 toba_framework
rm v3.4.8.tar.gz
```

#### Verificar descarga

```bash
ls -la toba_framework/
cat toba_framework/VERSION
```

---

### 2. Instalación de Dependencias

```bash
cd toba_framework
composer install
```

---

### 3. Instalación y Configuración de TOBA

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
exit
```

---

### 4. Configuración Final de Apache

```bash
docker-compose exec app ln -s /var/local/docker-data/framework-instalacion/toba.conf /etc/apache2/conf.d/toba_3_4.conf
docker-compose exec app httpd -t
docker-compose restart app
```

> **Nota Importante:** Este enlace simbólico se crea dentro del contenedor. Si en algún momento detienes el entorno con `docker-compose down`, el contenedor se eliminará y tendrás que volver a ejecutar este comando. Para pausar y reanudar el trabajo, utiliza `docker-compose stop` y `docker-compose start`.

---

### 5. Verificación de Instalación Exitosa

```bash
docker-compose logs app | tail -20
```

**Mensajes esperados en los logs:**
- `[INFO][toba] Se detecto cambio de operación. Se limpia la memoria de la operacion`
- `[DEBUG][toba_editor] INSTANCIA "desarrollo"`
- `[DEBUG][toba_editor] Parametros instancia desarrollo`
- Logs de acceso HTTP 200 exitosos
- Carga de recursos (imágenes, CSS, JS)

---

## Accesos Web Disponibles

- **🏠 http://localhost:8080/toba_editor/3.4** - Editor principal de TOBA
- **📚 http://localhost:8080/toba_referencia/3.4** - Ejemplos y documentación
- **👥 http://localhost:8080/toba_usuarios/3.4** - Gestión de usuarios

---

## Credenciales de Acceso

- **Usuario:** `toba`
- **Contraseña:** `toba`

---

## Proyectos Instalados

1. **toba_editor** - Editor y administrador del framework
2. **toba_referencia** - Ejemplos y casos de uso
3. **toba_usuarios** - Sistema de gestión de usuarios

---

## Comandos Útiles Post-Instalación

### Crear un Nuevo Proyecto

```bash
docker-compose exec app bash
source /var/local/docker-data/framework-instalacion/entorno_toba.env
toba proyecto crear
```

### Backup de la Base de Datos

```bash
docker-compose exec db pg_dump -U postgres toba_3_4 > backup_toba_$(date +%Y%m%d).sql
docker-compose exec -T db psql -U postgres toba_3_4 < backup_toba.sql
```

### Monitoreo y Logs

```bash
docker-compose logs -f app
docker-compose logs db
docker-compose exec app top
```

---

## Configuración de Desarrollo

El archivo `/var/local/docker-data/framework-instalacion/entorno_toba.env` contiene variables de entorno útiles para el desarrollo.

---

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

---

## Notas Importantes

- ✅ **Entorno de desarrollo** con usuario no privilegiado `siu`
- ✅ **Archivos editables** desde el host gracias al volumen montado
- ✅ **Base de datos persistente** en volumen Docker
- ✅ **TOBA 3.4.8** completamente funcional
- ✅ **PHP 8.2** con todas las extensiones necesarias
- 🔐 **Cambiar contraseña** del usuario `toba` en producción
- 📝 **Backup regular** de la base de datos recomendado

---

## Tiempo de Instalación

- **Descarga de TOBA:** ~2-3 minutos  
- **Composer install:** ~5-8 minutos
- **Instalación de TOBA:** ~1-2 minutos (76.9 segundos en el ejemplo)
- **Total estimado:** ~10-15 minutos

---

**🎉 ¡Instalación exitosa! TOBA 3.4.8 está listo para desarrollo.**
