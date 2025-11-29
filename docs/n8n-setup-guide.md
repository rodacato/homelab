# Guía de Configuración: n8n + Cloudflare Tunnel

Esta guía detalla cómo configurar n8n localmente utilizando Docker y exponerlo de forma segura a internet mediante Cloudflare Tunnel, sin necesidad de abrir puertos en el router.

## Prerrequisitos

1.  **Docker Desktop** instalado y corriendo.
2.  Un dominio gestionado en **Cloudflare**.
3.  Cuenta gratuita de **Cloudflare Zero Trust**.

## Paso 1: Configuración de Cloudflare Tunnel

1.  Accede al [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/).
2.  Navega a **Networks** > **Connectors** (o **Tunnels** en versiones anteriores).
3.  Haz clic en **Create Tunnel**.
4.  Selecciona **Cloudflared** como tipo de conector.
5.  Asigna un nombre al túnel (ej. `homelab`) y guarda.
6.  **Importante:** En la pantalla "Install and run a connector", copia **SOLO** el token que aparece después de `--token` en el comando de instalación.
    *   El token empieza por `eyJh...`.
    *   No copies el comando `brew install` ni `docker run`, solo el token.

## Paso 2: Configuración Local

1.  Asegúrate de tener el archivo `.env` creado en la raíz del proyecto (usa `.env.example` como base).
2.  Pega el token en la variable `CLOUDFLARED_TOKEN`:
    ```bash
    CLOUDFLARED_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
    ```
3.  Define tu dominio para n8n en `DOMAIN_N8N`:
    ```bash
    DOMAIN_N8N=n8n.tudominio.com
    ```
4.  Levanta los servicios:
    ```bash
    docker-compose up -d
    ```

## Paso 3: Enrutamiento en Cloudflare

Una vez que el contenedor `cloudflared` esté corriendo (puedes verificarlo con `docker-compose logs cloudflared`), vuelve al dashboard de Cloudflare.

1.  Verás que el conector aparece como **Connected**. Dale a "Next".
2.  En la pestaña **Public Hostnames** (o **Hostname routes** / **Published application routes**):
    *   **Subdomain:** `n8n` (o el que hayas elegido).
    *   **Domain:** Tu dominio (ej. `rubyc.mx`).
    *   **Service Type:** `HTTP`
    *   **URL:** `n8n:5678` (Usamos el nombre del servicio Docker, no localhost).
3.  Guarda la configuración.

¡Listo! Tu n8n debería ser accesible vía HTTPS en tu subdominio.

## Integración con IA Local (LM Studio)

Para usar tus modelos locales dentro de tus flujos de n8n:

1.  En n8n, añade el nodo **OpenAI**.
2.  En la configuración de **Credential**, selecciona "Create New".
3.  **API Key**: Escribe cualquier cosa (ej. `lm-studio`), no se valida pero es requerida.
4.  **Base URL**:
    *   Haz clic en la opción para cambiar la URL base (a veces escondida bajo "Show more" o "Custom URL").
    *   Introduce: `http://host.docker.internal:1234/v1`
5.  **Model**:
    *   En el nodo, selecciona "Model" -> "Other" (o escribe manualmente el ID del modelo).
    *   El ID suele ser el nombre del archivo en LM Studio, pero a menudo basta con poner `local-model` si solo tienes uno cargado.
6.  ¡Prueba el nodo! Debería responder usando tu LM Studio.

## Troubleshooting (Solución de Problemas)

### 1. Error: "Provided Tunnel token is not valid"
*   **Síntoma:** El contenedor `cloudflared` se reinicia constantemente.
*   **Causa:** Copiaste el comando entero de instalación en lugar de solo el token, o hay espacios/comillas extra en el `.env`.
*   **Solución:** Edita el `.env` y asegúrate de que `CLOUDFLARED_TOKEN` contenga solo la cadena alfanumérica larga.

### 2. Error 502 Bad Gateway al descargar imagen n8n
*   **Síntoma:** Docker falla al descargar la imagen `docker.n8n.io/n8nio/n8n`.
*   **Causa:** El registro privado de n8n a veces tiene problemas de conexión.
*   **Solución:** Cambia la imagen en `docker-compose.yml` para usar Docker Hub:
    ```yaml
    image: n8nio/n8n:latest
    ```

### 3. n8n no carga o da error de Webhook
*   **Síntoma:** La interfaz carga pero avisa de problemas con webhooks, o no carga los cambios de dominio.
*   **Causa:** Las variables de entorno cambiaron pero el contenedor no se reinició.
*   **Solución:** Fuerza el recreado del contenedor n8n:
    ```bash
    docker-compose up -d --force-recreate n8n
    ```

### 4. No encuentro "Tunnels" en Cloudflare
*   **Causa:** Cloudflare actualizó su interfaz recientemente.
*   **Solución:** Busca dentro de **Networks** > **Connectors**. Ahí podrás crear y gestionar tus túneles.
