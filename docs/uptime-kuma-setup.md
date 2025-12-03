# Guía de Configuración: Uptime Kuma

Uptime Kuma es una herramienta de monitoreo auto-hospedada similar a "Uptime Robot".

## Acceso Local

El servicio está configurado en el puerto `8083`.
*   **URL**: `http://localhost:8083`

## Configuración de Cloudflare Tunnel

Para acceder desde `https://status.notdefined.dev`:

1.  Ve a **Networks** > **Tunnels** en Cloudflare Zero Trust.
2.  Edita tu túnel y añade un **Public Hostname**:
    *   **Subdomain**: `status` (o `monitor`)
    *   **Domain**: `notdefined.dev`
    *   **Service Type**: `HTTP`
    *   **URL**: `uptime-kuma:3001` (Puerto interno del contenedor)

## Configuración Inicial

1.  Abre la URL por primera vez.
2.  Crea tu cuenta de administrador.
3.  Empieza a añadir monitores (ej. `http://homepage:3000`, `http://n8n:5678`).

## Volúmenes

Los datos se persisten en el volumen `uptime_kuma_data`, por lo que no perderás tu historial si reinicias el contenedor.
