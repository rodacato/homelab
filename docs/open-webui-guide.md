# Guía de Configuración: Open WebUI + LM Studio

Esta guía detalla cómo configurar **Open WebUI** (anteriormente Ollama WebUI) para que funcione como tu interfaz de chat principal, conectándose a los modelos de IA que corren en tu Windows (LM Studio) y exponiéndolo de forma segura a internet.

## ¿Qué es Open WebUI?

Es una interfaz de chat moderna, muy similar a ChatGPT, que te permite interactuar con tus modelos locales.
*   **Frontend**: Open WebUI (corre en Docker).
*   **Backend (IA)**: LM Studio (corre en Windows).

## Prerrequisitos

1.  **LM Studio** instalado en Windows.
2.  **Docker Desktop** corriendo con integración WSL 2.
3.  Un túnel de **Cloudflare** activo (ver guía de n8n).

## Paso 1: Configurar LM Studio (Backend)

Para que Docker pueda "ver" a LM Studio, necesitamos activar su modo servidor.

1.  Abre **LM Studio**.
2.  Ve a la pestaña **Local Server** (ícono de doble flecha `<->` en la izquierda).
3.  En el panel derecho, asegúrate de que el puerto sea `1234`.
4.  Haz clic en **Start Server**.
    *   Deberías ver logs verdes indicando que está escuchando.
5.  **Carga un modelo**: Ve a la lupa (Search), descarga un modelo (ej. `Llama 3` o `Mistral`) y cárgalo en la barra superior (botón verde "Load").

## Paso 2: Verificar Conexión en Open WebUI

Open WebUI ya está pre-configurado en este repositorio para buscar a LM Studio en `host.docker.internal:1234`.

1.  Accede a [http://localhost:3001](http://localhost:3001).
2.  Crea tu cuenta de administrador (el primer usuario que se registra es admin).
3.  Ve a **Settings** (tu perfil abajo a la izquierda) -> **Connections**.
4.  **IMPORTANTE (Desactivar Ollama)**:
    *   Como no estamos usando Ollama, verás un error en rojo intentando conectar a `http://host.docker.internal:11434`.
    *   **Apaga el interruptor** que dice "Ollama API" (o simplemente ignora el error). No puedes conectar la sección de "Ollama" a LM Studio.
5.  **Verificar OpenAI (LM Studio)**:
    *   Baja a la sección **OpenAI API**.
    *   Verifica que la URL sea: `http://host.docker.internal:1234/v1`.
    *   Haz clic en el botón de verificar (flecha circular o guardar). Si sale verde, ¡estás conectado!
6.  Abre un **New Chat** y selecciona tu modelo en el menú desplegable superior.

## Paso 3: Exponer a Internet (Cloudflare Tunnel)

Para acceder a tu chat desde cualquier lugar (ej. `chat.tudominio.com`):

1.  Ve al [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/).
2.  Ve a **Networks** > **Tunnels** y edita tu túnel existente (`Configure`).
3.  Ve a la pestaña **Public Hostnames**.
4.  Añade una nueva ruta (**Add a public hostname**):
    *   **Subdomain**: `chat` (o `ai`, `gpt`, lo que prefieras).
    *   **Domain**: Tu dominio.
    *   **Path**: (Déjalo vacío).
    *   **Service Type**: `HTTP`.
    *   **URL**: `open-webui:8080`.
        *   *Nota: Usamos `open-webui` porque es el nombre del servicio dentro de la red de Docker. El puerto interno del contenedor es 8080 (aunque afuera lo veamos en 3001).*
5.  Guarda la configuración (**Save hostname**).

¡Listo! Ahora puedes entrar a `https://chat.tudominio.com` y usar tu IA privada desde el móvil o cualquier PC.

## Troubleshooting (Solución de Problemas)

### 1. No veo modelos en la lista
*   **Causa**: LM Studio no tiene ningún modelo cargado en la memoria RAM.
*   **Solución**: En LM Studio, asegúrate de que la barra verde superior muestre un modelo cargado (ej. `Loaded: Llama-3...`). Si dice "Select a model to load", no funcionará.

### 2. Error de conexión "Connection refused"
*   **Causa**: El servidor de LM Studio está apagado o el firewall de Windows bloquea la conexión.
*   **Solución**:
    *   Confirma que el botón "Start Server" esté presionado.
    *   Si sigue fallando, prueba desactivar temporalmente el firewall de Windows para descartar que sea eso.

### 3. Open WebUI va lento
*   **Causa**: Tu PC está procesando la IA. La velocidad depende 100% de tu tarjeta gráfica (GPU) y RAM.
*   **Solución**: Usa modelos "quantized" (ej. `Q4_K_M`) que son más ligeros y rápidos.
