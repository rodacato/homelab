# Guía de Configuración: Portainer CE + Cloudflare Tunnel

Esta guía detalla cómo configurar Portainer CE para gestionar tu entorno Docker y exponerlo de forma segura a internet mediante Cloudflare Tunnel.

## Prerrequisitos

1.  **Docker Desktop** instalado y corriendo.
2.  **Cloudflare Tunnel** configurado (ver `n8n-setup-guide.md` para referencia de configuración básica).

## Paso 1: Configuración en Docker Compose

El servicio de Portainer ya ha sido añadido a tu archivo `docker-compose.yml`.

```yaml
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    networks:
      - homelab-net
```

Para iniciar el servicio, ejecuta:

```bash
docker-compose up -d portainer
```

## Paso 2: Configuración Inicial de Portainer

1.  Abre tu navegador y ve a `http://localhost:9000`.
2.  Verás la pantalla de configuración inicial.
3.  **Username**: `admin` (o el que prefieras).
4.  **Password**: Crea una contraseña segura (mínimo 12 caracteres).
5.  Haz clic en **Create user**.
6.  Selecciona **Get Started** para conectar con el entorno Docker local (detectado automáticamente gracias al volumen `/var/run/docker.sock`).

## Paso 3: Exponer Portainer con Cloudflare Tunnel

Para acceder a Portainer desde `https://portainer.notdefined.dev`, necesitas configurar el túnel en Cloudflare.

1.  Accede al [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/).
2.  Ve a **Networks** > **Tunnels** y selecciona tu túnel existente.
3.  Haz clic en **Configure** > **Public Hostname**.
4.  Añade un nuevo hostname:
    *   **Subdomain**: `portainer`
    *   **Domain**: `notdefined.dev`
    *   **Path**: (dejar vacío)
    *   **Service Type**: `HTTP`
    *   **URL**: `portainer:9000`
5.  Guarda la configuración.

> [!NOTE]
> Usamos `portainer:9000` como URL porque ambos contenedores (`cloudflared` y `portainer`) están en la misma red Docker (`homelab-net`).

## Verificación

1.  Accede a `https://portainer.notdefined.dev`.
2.  Deberías ver la pantalla de inicio de sesión de Portainer.
