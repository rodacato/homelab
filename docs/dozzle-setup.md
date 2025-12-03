# Guía de Configuración: Dozzle (Visor de Logs)

Dozzle es una interfaz ligera basada en web para monitorear los logs de tus contenedores Docker en tiempo real.

## Acceso Local

El servicio está configurado en el puerto `9999`.
*   **URL**: `http://localhost:9999`

## Configuración de Cloudflare Tunnel

Para acceder desde `https://dozzle.notdefined.dev`:

1.  Ve a **Networks** > **Tunnels** en Cloudflare Zero Trust.
2.  Edita tu túnel y añade un **Public Hostname**:
    *   **Subdomain**: `dozzle`
    *   **Domain**: `notdefined.dev`
    *   **Service Type**: `HTTP`
    *   **URL**: `dozzle:8080` (Puerto interno del contenedor)

## Autenticación

## Autenticación

Por seguridad, hemos habilitado autenticación básica mediante el archivo `dozzle/users.yml`.
*   **Usuario**: `rodacato`
*   **Contraseña**: (Tu contraseña configurada)

> [!IMPORTANT]
> Dozzle ya no soporta configurar contraseñas directamente en `.env`.
> Para cambiar la contraseña, debes generar un nuevo hash y actualizar `dozzle/users.yml`.
>
> **Comando para generar nuevo usuario/contraseña:**
> ```bash
> docker run --rm amir20/dozzle:latest generate --password <TU_NUEVA_PASSWORD> <TU_USUARIO>
> ```
> Luego copia el resultado en `dozzle/users.yml` y reinicia el contenedor.

## Gestión de Usuarios y Contraseñas

Si necesitas cambiar tu contraseña o agregar más usuarios en el futuro:

1.  **Generar el hash de la nueva contraseña**:
    Ejecuta el siguiente comando en tu terminal (reemplaza `<NUEVA_PASSWORD>` y `<USUARIO>`):
    ```bash
    docker run --rm amir20/dozzle:latest generate --password <NUEVA_PASSWORD> <USUARIO>
    ```

2.  **Actualizar el archivo de configuración**:
    Copia la salida del comando anterior y reemplaza el contenido de `homelab/dozzle/users.yml`.
    *El formato debe verse así:*
    ```yaml
    users:
        rodacato:
            email: ""
            name: ""
            password: $2a$11$HASH_LARGO_Y_COMPLEJO...
            filter: ""
            roles: ""
    ```

3.  **Reiniciar Dozzle**:
    ```bash
    docker-compose restart dozzle
    ```

### Troubleshooting
*   **"Unexpected environment variable"**: Si ves este error en los logs, es porque estás usando una versión reciente de Dozzle que no soporta `DOZZLE_USERNAME` en el `.env`. Debes usar el método de `users.yml` descrito arriba.
