# Guía de Configuración: ComfyUI (Generación de Imágenes)

Esta guía explica cómo integrar **ComfyUI** (que corre en Windows) con tu Homelab en Docker.

## Paso 1: Instalación (Versión Portable)
**IMPORTANTE**: No uses la "App de Escritorio". Descarga la versión **Portable**.

1.  **Descarga**: [ComfyUI_windows_portable_nvidia_cu121_or_cpu.7z](https://github.com/comfyanonymous/ComfyUI/releases/download/latest/ComfyUI_windows_portable_nvidia_cu121_or_cpu.7z)
    *   *Fuente oficial*: [GitHub Releases](https://github.com/comfyanonymous/ComfyUI/releases)
2.  **Descomprime** el archivo (usa 7-Zip o WinRAR) en una carpeta como `C:\ComfyUI`.
3.  **Configura el acceso externo**:
    *   Busca el archivo `run_nvidia_gpu.bat`.
    *   Click derecho -> **Editar**.
    *   Añade `--listen` al final de la línea.
    *   Ejemplo: `.\python_embeded\python.exe ... main.py ... --listen`
4.  **Ejecuta**: Doble click en `run_nvidia_gpu.bat`.
5.  Se abrirá una ventana negra (consola) y luego el navegador. ¡Listo!

## Paso 1.5: Descargar Modelos (Checkpoints)
ComfyUI viene vacío. Necesitas descargar un "cerebro" para pintar.

| Modelo | Archivo (Nombre para Open WebUI) | Descarga | Recomendado para |
| :--- | :--- | :--- | :--- |
| **Flux.1 [dev]** | `flux1-dev-fp8.safetensors` | [HuggingFace Link](https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors) | **Calidad Máxima**. Realismo puro. (Requiere ~12GB VRAM). |
| **Juggernaut XL** | `Juggernaut-XL-v9.safetensors` | [Civitai Link](https://civitai.com/api/download/models/357609) | **Balance**. Muy bueno y más rápido que Flux. |
| **DreamShaper 8** | `dreamshaper_8.safetensors` | [Civitai Link](https://civitai.com/api/download/models/128713) | **Velocidad**. Estilo artístico/anime. Muy ligero. |

1.  Descarga el archivo.
2.  Ponlo en `ComfyUI\models\checkpoints`.
3.  Dale a **Refresh** en ComfyUI.
4.  Copia el nombre exacto (columna 2) en la configuración de Open WebUI.

## Paso 2: Configurar Open WebUI
Ya hemos pre-configurado las variables de entorno, pero verifica en la interfaz:

1.  Ve a **Admin Panel** -> **Settings** -> **Images**.
2.  **Image Generation Engine**: Debe decir `comfyui`.
3.  **ComfyUI Base URL**: Debe decir `http://host.docker.internal:8188/`.
4.  **Model**: Aquí debes poner el **nombre exacto del archivo** de tu modelo.
    *   *Ejemplo*: `flux1-dev.safetensors` o `v1-5-pruned.ckpt`.
    *   *¿Dónde lo veo?*: Mira en tu carpeta `ComfyUI\models\checkpoints`. Si está vacía, ¡necesitas descargar uno!
    *   *Recomendación*: Descarga **Flux.1 [dev]** (si tienes 12GB VRAM) o **SDXL Lightning** (más rápido).
5.  **Activa el switch**: "Image Generation" (ON).
6.  Dale a **Save**.

### ¿Cómo usarlo?
En cualquier chat, simplemente escribe:
> "Genera una imagen de un gato cyberpunk"

Open WebUI detectará la intención y mandará la orden a ComfyUI.

## Paso 3: Conectar con n8n
Para automatizar imágenes (ej. "Crear imagen para post de Instagram"):

1.  Usa el nodo **HTTP Request**.
2.  **Method**: POST.
3.  **URL**: `http://host.docker.internal:8188/prompt`.
4.  **Body**: Tienes que enviar el JSON del workflow de ComfyUI.
    *   *Tip: En ComfyUI, activa "Enable Dev Mode Options" en la configuración (engranaje). Luego verás un botón "Save (API Format)" para obtener el JSON exacto.*

## Solución de Problemas
*   **Error de conexión**: Asegúrate de que ComfyUI esté corriendo en la ventana negra (terminal).
*   **Lentitud**: Recuerda usar un modelo de chat ligero (8B) mientras generas imágenes para no saturar tu GPU.
