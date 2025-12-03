# Guía de Configuración: Homepage

Homepage es un dashboard moderno y altamente personalizable para tu homelab.

## Acceso Local

El servicio está configurado en el puerto `8082`.
*   **URL**: `http://localhost:8082`

## Configuración de Cloudflare Tunnel

Para acceder desde `https://home.notdefined.dev`:

1.  Ve a **Networks** > **Tunnels** en Cloudflare Zero Trust.
2.  Edita tu túnel y añade un **Public Hostname**:
    *   **Subdomain**: `home`
    *   **Domain**: `notdefined.dev`
    *   **Service Type**: `HTTP`
    *   **URL**: `homepage:3000` (Puerto interno del contenedor)

## Personalización

La configuración se encuentra en la carpeta `homepage/config/` de tu proyecto.

### Archivos Principales:
*   `services.yaml`: Define los servicios y aplicaciones que se muestran.
*   `widgets.yaml`: Configura widgets de información (CPU, Clima, etc.).
*   `bookmarks.yaml`: Enlaces rápidos a sitios externos.
*   `settings.yaml`: Configuración general (título, tema, fondo).

### Integración con Docker
Homepage tiene acceso a `/var/run/docker.sock`, lo que permite mostrar el estado (running/stopped) de tus contenedores automáticamente si se configuran correctamente en `services.yaml`.

Ejemplo para `services.yaml`:
```yaml
- My Group:
    - My App:
        server: my-docker # Definido en docker.yaml (opcional) o automático
        container: container_name_in_docker_compose
```
