# Corrección de Assets de Bootstrap

## Problema

El comando `composer run-script post-install-cmd -d ./vendor/siu/manejador-salida-bootstrap/` falla porque el script `instalar_assets.php` calcula incorrectamente la ruta del framework Toba.

### Causa técnica

El script busca la ruta `$vendor_dir/siu-toba/framework` pero en esta instalación el framework está en `$vendor_dir` directamente, causando que `$path_toba` sea `null` y genere rutas incorrectas como `/www/siu/manejador_salida_bootstrap`.

## Solución

### Opción 1: Script automático (Recomendado)

Ejecutar desde la raíz del proyecto:

```bash
./docker/scripts/install-bootstrap.sh
```

### Opción 2: Manual dentro del contenedor

```bash
cd /home/usuario/development/template-toba/
docker-compose exec app /usr/local/app/docker/scripts/fix-bootstrap-assets.sh
```

### Opción 3: Integración permanente en Dockerfile

Para hacer esta corrección permanente, agregar al `Dockerfile`:

```dockerfile
# Copiar script de corrección
COPY docker/scripts/fix-bootstrap-assets.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/fix-bootstrap-assets.sh

# Ejecutar después de composer install
RUN fix-bootstrap-assets.sh
```

## Archivos creados

- `docker/scripts/fix-bootstrap-assets.sh` - Script de corrección principal
- `docker/scripts/install-bootstrap.sh` - Script de conveniencia para ejecutar desde host
- `docs/Bootstrap-Assets-Fix.md` - Esta documentación

## Verificación

Los assets deben quedar instalados en:
- `/usr/local/app/toba_framework/www/siu/manejador_salida_bootstrap/`

Con la siguiente estructura:
```
manejador_salida_bootstrap/
├── css/
│   ├── fontawesome/          # FontAwesome completo
│   ├── global.css
│   └── ...
├── js/
│   ├── bootstrap/            # Bootstrap JS y CSS
│   ├── respond.js/           # Respond.js para IE8
│   ├── html5shiv/           # HTML5Shiv para IE
│   └── ...
└── img/                     # Imágenes del manejador
```