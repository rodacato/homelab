# Guía de Configuración: Homelab Local LLM en Windows

Esta guía detalla cómo configurar tu máquina Windows para correr modelos de IA locales (LLMs) usando tu GPU NVIDIA, integrados con n8n y expuestos de forma segura.

## Prerrequisitos

1.  **Windows 10/11 Pro** (Recomendado).
2.  **Drivers de NVIDIA** actualizados.
3.  **WSL2** instalado y configurado.
    *   Abre PowerShell como Admin y ejecuta: `wsl --install`
    *   Reinicia la computadora.
4.  **Docker Desktop para Windows**.
    *   En la configuración de Docker > Resources > WSL 2 integration: Asegúrate de que tu distribución de Linux (ej. Ubuntu) esté marcada.
    *   En Docker > Settings > General: Marca "Use the WSL 2 based engine".

## Instalación

1.  **Clonar/Copiar el Repositorio**:
    Copia tu carpeta `homelab` a tu máquina Windows (o clónala si usas git).

2.  **Variables de Entorno**:
    Asegúrate de tener tu archivo `.env` en la misma carpeta con tus credenciales:
    ```env
    CLOUDFLARED_TOKEN=tu_token_aqui
    DOMAIN_N8N=n8n.tudominio.com
    TIMEZONE=America/Mexico_City
    ```

3.  **Arrancar los Servicios**:
    Abre una terminal (PowerShell o CMD) en la carpeta `homelab` y ejecuta:

    ```powershell
    docker compose -f docker-compose.windows.yml up -d
    ```

## Verificación

1.  **Ollama (API)**:
    Verifica que Ollama esté corriendo y detecte la GPU.
    *   Desde tu navegador en Windows: `http://localhost:11434` (Debería decir "Ollama is running").
    *   Para descargar un modelo (ej. Llama 3):
        ```powershell
        docker exec -it ollama ollama run llama3
        ```
        *Esto descargará el modelo (varios GBs) y te dejará chatear en la terminal.*

2.  **Open WebUI**:
    *   Entra a `http://localhost:3001`.
    *   Crea una cuenta (es local, solo vive en tu base de datos).
    *   Selecciona el modelo "llama3" arriba y empieza a chatear.

3.  **n8n**:
    *   Entra a tu dominio `https://n8n.tudominio.com`.
    *   Crea un nuevo workflow.
    *   Agrega el nodo **"Ollama Basic Chat Model"**.
    *   En credenciales/host, normalmente no necesitas nada si estás en la misma red de docker, pero si te pide Base URL usa: `http://ollama:11434`.
    *   ¡Prueba generar texto!

## Solución de Problemas

*   **Error de GPU**: Si el contenedor de Ollama falla o no usa la GPU, verifica que los drivers de NVIDIA estén instalados en Windows y que Docker Desktop tenga habilitado el soporte de GPU (normalmente es automático con WSL2).
*   **Conectividad**: Si n8n no conecta con Ollama, asegúrate de usar `http://ollama:11434` como host dentro de n8n, ya que `ollama` es el nombre del servicio en el docker-compose.

## Alternativa: Usar LM Studio (Windows)

Si prefieres usar **LM Studio** en lugar de Ollama (por su interfaz gráfica o facilidad para probar modelos GGUF), puedes integrarlo con tu Homelab.

### Comparativa
| Característica | Ollama (Docker) | LM Studio (Windows App) |
| :--- | :--- | :--- |
| **Rol** | Servidor "Headless" (ideal para 24/7) | Aplicación de Escritorio (ideal para pruebas) |
| **Gestión** | Vía CLI o WebUI externa | Interfaz Gráfica Nativa |
| **Integración** | Directa en red Docker | Requiere configuración de red (Host) |
| **Recursos** | Optimizado, corre en fondo | Consume recursos de UI, debe estar abierto |

### Configuración para LM Studio

1.  **En LM Studio**:
    *   Ve a la pestaña de **"Local Server"** (icono de `<->`).
    *   Inicia el servidor.
    *   **Importante**: Asegúrate de que escuche en todas las interfaces o permite conexiones externas (por defecto es `localhost`, necesitas que Docker lo vea). Puede que necesites cambiar la configuración a `0.0.0.0` o permitir acceso en el Firewall de Windows.

2.  **En n8n (Docker)**:
    *   Como LM Studio corre en el "Host" (Windows) y n8n en Docker, no puedes usar `localhost`.
    *   Usa la dirección especial: `http://host.docker.internal:1234/v1` (el puerto por defecto de LM Studio es 1234).
    *   En el nodo de n8n, selecciona "OpenAI" (LM Studio es compatible con OpenAI) y pon esa URL como Base URL.

3.  **En `docker-compose.windows.yml`**:
    *   Puedes comentar/borrar el servicio de `ollama` y `open-webui` si solo vas a usar LM Studio.
    *   Asegúrate de que n8n tenga acceso al host (normalmente automático en Docker Desktop para Windows).

