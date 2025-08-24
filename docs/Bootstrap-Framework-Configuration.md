# Configuración de Bootstrap en Framework Toba

## Descripción

Script para corregir automáticamente los scripts de instalación de assets Bootstrap en el framework Toba global, solucionando problemas de rutas incorrectas en `composer.json`.

## Problema a resolver

El framework Toba 3.4.8 ya incluye:
- ✅ Dependencia `siu/manejador-salida-bootstrap: ^1.4`
- ✅ Scripts post-install y post-update configurados
- ❌ **Scripts con rutas incorrectas** que causan errores

### Ruta problemática actual:
```bash
composer run-script post-install-cmd -d ./vendor/siu/manejador-salida-bootstrap/
```

### Ruta corregida:
```bash
fix-bootstrap-assets.sh
```

## Uso del Script

```bash
# Desde el host (después de reconstruir contenedor)
cd /home/usuario/development/template-toba/
docker-compose exec app /usr/local/app/docker/scripts/fix-framework-bootstrap.sh

# O directamente desde el contenedor
docker-compose exec app bash
fix-framework-bootstrap.sh
```

## Lo que hace el script

1. **Lee el composer.json global** del framework (`/usr/local/app/toba_framework/composer.json`)
2. **Localiza los comandos problemáticos** en `post-install-cmd` y `post-update-cmd`
3. **Los reemplaza** con `fix-bootstrap-assets.sh`
4. **Mantiene intacto** el resto de la configuración

## Resultado

Después de ejecutar el script, `composer install` y `composer update` en el framework ejecutarán automáticamente la corrección de assets de Bootstrap.

## Proceso completo desde cero

```bash
# 1. Eliminar contenedores
docker-compose down -v

# 2. Reconstruir con Dockerfile actualizado
docker-compose up -d --build

# 3. Corregir scripts del framework
docker-compose exec app fix-framework-bootstrap.sh

# 4. Instalar framework (ahora funciona correctamente)
docker-compose exec app bash -c "cd /usr/local/app/toba_framework && composer install"
```

## Archivos relacionados

- `docker/scripts/fix-framework-bootstrap.sh` - Script de corrección del framework
- `docker/scripts/fix-bootstrap-assets.sh` - Script de instalación de assets
- `docs/Bootstrap-Assets-Fix.md` - Documentación del problema de assets
- `docs/Bootstrap-Framework-Configuration.md` - Esta documentación

## Verificación

Los assets quedan instalados en:
- `/usr/local/app/toba_framework/www/siu/manejador_salida_bootstrap/`

Para usar Bootstrap en cualquier proyecto:
```php
$conf['manejador_salida'] = 'bootstrap';
```