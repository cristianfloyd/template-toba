# Guía de Desarrollo - Toba UBA MG

Esta guía explica cómo configurar y desarrollar con el entorno Toba UBA MG usando la imagen Docker pre-configurada.

## Setup Automático (Recomendado)

```bash
# 1. Clonar repositorio
git clone https://github.com/cristianfloyd/template-toba.git
cd template-toba

# 2. Ejecutar setup automático
./scripts/dev-setup.sh
```

**¡Listo!** En ~2 minutos tendrás:
- Framework Toba funcionando
- Base de datos con datos del proyecto
- Código PHP local para editar en VS Code

## Desarrollo con VS Code

### Estructura del Proyecto
```
template-toba/
├── uba_mg/                    # 📝 Código PHP del proyecto (EDITABLE)
│   ├── php/                   # Lógica de negocio
│   │   ├── operaciones/       # Operaciones Toba
│   │   ├── reportes/          # Reportes y exportaciones
│   │   └── extension_toba/    # Extensiones del framework
│   ├── metadatos/             # Configuración de componentes
│   ├── www/                   # Assets web (CSS, JS, imágenes)
│   └── sql/                   # Migraciones y scripts SQL
└── docker-compose.distribution.yml
```

### Flujo de Desarrollo

1. **Abrir VS Code**
   ```bash
   code ./uba_mg
   ```

2. **Editar código PHP**
   - Los cambios se reflejan **inmediatamente**
   - No necesitas reiniciar contenedores
   - Hot reload automático

3. **Ver cambios**
   - Aplicación: http://localhost:8080
   - Logs: `docker-compose -f docker-compose.distribution.yml logs -f app`

## Desarrollo de Componentes Toba

### Operaciones PHP
```php
// uba_mg/php/operaciones/mi_operacion.php
<?php
class mi_operacion extends uba_mg_modelo 
{
    function configurar() {
        // Tu lógica aquí
    }
}
```

### Cuadros de Datos
```php
// uba_mg/php/operaciones/ci_mi_cuadro.php
<?php
class ci_mi_cuadro extends toba_ei_cuadro
{
    function conf_evt__procesar($evento, $fila) {
        // Procesar datos del cuadro
    }
}
```

### CSS y Assets
```css
/* uba_mg/www/css/toba.css */
.mi-componente {
    /* Estilos personalizados */
}
```

## Base de Datos

### Acceso Directo
```bash
# Conectar a PostgreSQL
docker-compose -f docker-compose.distribution.yml exec db psql -U postgres -d toba_3_4

# Ver tablas del proyecto
\dt uba_mg.*
```

### Migraciones
```sql
-- uba_mg/sql/migrations/nueva_version.sql
ALTER TABLE uba_mg.mi_tabla ADD COLUMN nueva_columna VARCHAR(100);
```

## Comandos Útiles

### Contenedores
```bash
# Ver estado
docker-compose -f docker-compose.distribution.yml ps

# Logs en tiempo real
docker-compose -f docker-compose.distribution.yml logs -f app

# Acceder al contenedor
docker-compose -f docker-compose.distribution.yml exec app bash

# Reiniciar servicios
docker-compose -f docker-compose.distribution.yml restart
```

### Toba Framework
```bash
# Acceder al contenedor
docker-compose exec app bash

# Comandos Toba (dentro del contenedor)
cd /usr/local/app/toba_framework
./bin/toba proyecto -p uba_mg

# Compilar metadatos
./bin/toba compilar -p uba_mg
```

## Debugging

### Logs de PHP
```bash
# Ver logs de Apache/PHP
docker-compose -f docker-compose.distribution.yml exec app tail -f /var/log/apache2/error.log
```

### Debugging con Xdebug
El contenedor incluye Xdebug configurado:

```json
// .vscode/launch.json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/usr/local/app/toba_framework/proyectos/uba_mg": "${workspaceFolder}/uba_mg"
            }
        }
    ]
}
```

## Extensiones de VS Code Recomendadas

```json
// .vscode/extensions.json
{
    "recommendations": [
        "bmewburn.vscode-intelephense-client",
        "ms-vscode.vscode-json",
        "bradlc.vscode-tailwindcss",
        "formulahendry.auto-rename-tag"
    ]
}
```

## Resolución de Problemas

### Error: Permisos de archivos
```bash
# Ajustar permisos
sudo chown -R $USER:$USER ./uba_mg
chmod -R 755 ./uba_mg
```

### Error: Puerto en uso
```bash
# Cambiar puerto en docker-compose.distribution.yml
ports:
  - "8081:80"  # En lugar de 8080
```

### Error: Contenedor no inicia
```bash
# Ver logs detallados
docker-compose -f docker-compose.distribution.yml logs app

# Verificar imagen
docker-compose -f docker-compose.distribution.yml pull
```

### Código no actualiza
```bash
# Verificar montaje de volumen
docker-compose -f docker-compose.distribution.yml exec app ls -la /usr/local/app/toba_framework/proyectos/uba_mg

# Reiniciar Apache
docker-compose -f docker-compose.distribution.yml exec app service apache2 reload
```

## Consejos de Desarrollo

1. **Usa Git** para el código en `./uba_mg/`
2. **Backup regular** de la base de datos durante desarrollo
3. **Compilar metadatos** después de cambios en componentes Toba
4. **Logs siempre activos** para debugging
5. **Extensiones PHP** de VS Code para mejor experience

## URLs Importantes

- **Aplicación**: http://localhost:8080
- **Toba Admin**: http://localhost:8080/toba_framework/php/admin/
- **Database**: localhost:7432 (postgres/postgres)

---

💡 **Tip**: Mantén siempre activos los logs con `docker-compose -f docker-compose.distribution.yml logs -f app` en una terminal separada.