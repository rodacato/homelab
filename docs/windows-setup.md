# Guía de Configuración para Windows (WSL 2) - LM Studio Only

Esta guía te ayudará a desplegar tu Homelab en Windows utilizando Docker Desktop y WSL 2, utilizando **LM Studio** como tu motor de IA exclusivo.

## Prerrequisitos

1.  **WSL 2**: Asegúrate de tener WSL 2 instalado y configurado.
2.  **Docker Desktop**: Instalado y configurado para usar el backend de WSL 2.
3.  **Git**: Instalado en tu entorno WSL (Ubuntu/Debian).
4.  **LM Studio**: **Requerido**. Debe estar instalado en Windows.

## Pasos de Instalación

### 1. Preparar el Entorno

Abre tu terminal de WSL (ej. Ubuntu) y clona el repositorio si aún no lo has hecho:

```bash
git clone <tu-repo-url>
cd homelab
```

### 2. Configuración de Variables

Copia el archivo de ejemplo `.env.example` a `.env`:

```bash
cp .env.example .env
```

Edita el archivo `.env` con tus credenciales:
- `CLOUDFLARED_TOKEN`: Tu token del túnel de Cloudflare.
- `DOMAIN_N8N`: Tu dominio para n8n (ej. `n8n.tudominio.com`).
- `TIMEZONE`: Tu zona horaria (ej. `America/Mexico_City`).

### 3. Iniciar LM Studio (CRÍTICO)

Dado que no estamos usando Ollama, **LM Studio DEBE estar corriendo** para que la IA funcione.

1.  Abre **LM Studio** en Windows.
2.  Ve a la pestaña de **Servidor Local** (ícono de doble flecha <->).
3.  Inicia el servidor (Start Server). Por defecto corre en el puerto `1234`.
4.  **Verificación**: Asegúrate de que el servidor esté activo antes de iniciar los contenedores.

### 4. Ejecutar Servicios

Usa el archivo de composición específico para Windows:

```bash
docker-compose -f docker-compose.windows.yml up -d
```

### 5. Verificar Acceso

- **Open WebUI**: `http://localhost:3001`
    - Debería conectarse automáticamente a tu LM Studio.
    - Si no ves modelos, asegúrate de haber cargado uno en LM Studio.
- **n8n**: `http://localhost:5678`
    - Para usar IA en n8n, usa el nodo **OpenAI**.
    - En las credenciales del nodo, selecciona "Custom URL" o "Base URL" y pon: `http://host.docker.internal:1234/v1`.

## Solución de Problemas

- **Open WebUI no ve modelos**:
    - Confirma que cargaste un modelo en LM Studio (el botón verde "Load" en la parte superior).
    - Confirma que el servidor de LM Studio está en verde (Running).
- **Errores de conexión**:
    - Prueba `curl http://host.docker.internal:1234/v1/models` desde tu terminal WSL. Si falla, revisa el firewall de Windows o la configuración de LM Studio.
