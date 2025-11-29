# Guía de Configuración: Qdrant (Memoria Vectorial)

Esta guía explica cómo verificar y conectar **Qdrant**, tu base de datos vectorial para dar "memoria a largo plazo" a tu IA.

## ¿Qué es Qdrant?
Es una base de datos especializada en guardar "significados" (vectores) en lugar de solo palabras exactas. Permite que n8n o tu IA busquen documentos por contexto (ej. buscar "facturas de luz" y encontrar archivos llamados "CFE_Enero.pdf").

## Paso 1: Instalación
Ya está incluido en tu `docker-compose.windows.yml`. Para iniciarlo:

```bash
docker-compose -f docker-compose.windows.yml up -d
```

## Paso 2: Verificación
Qdrant tiene un panel de control web muy útil.
1.  Abre en tu navegador: [http://localhost:6333/dashboard](http://localhost:6333/dashboard)
2.  Deberías ver una interfaz oscura que dice "Qdrant Dashboard".
3.  Si ves "Collections" (aunque esté vacío), ¡está funcionando!

## Paso 3: Conectar con n8n (El Cerebro)
Qdrant **NO** se conecta directo a LM Studio. **n8n es el intermediario**.

1.  **n8n -> Qdrant**: Para guardar/leer datos.
    *   Nodo: **Qdrant**.
    *   Credencial URL: `http://qdrant:6333`.
2.  **n8n -> LM Studio**: Para convertir texto a números (Embeddings).
    *   Nodo: **Embeddings OpenAI**.
    *   Credencial URL: `http://host.docker.internal:1234/v1`.

### Flujo de Trabajo (Cómo funciona juntos)
Imagina que quieres que tu IA lea un PDF:

1.  **n8n** lee el PDF.
2.  **n8n** le envía el texto a **LM Studio** y le dice: *"Conviérteme esto en números (vectores)"*.
3.  **LM Studio** devuelve los números.
4.  **n8n** guarda esos números en **Qdrant**.

Cuando preguntas algo:
1.  **n8n** convierte tu pregunta en números (con LM Studio).
2.  **n8n** busca en **Qdrant**: *"¿Qué números se parecen a mi pregunta?"*.
3.  **Qdrant** devuelve el trozo del PDF relevante.
4.  **n8n** se lo pasa a la IA para que te responda.

## ¿Debo exponer Qdrant a Internet?
**Generalmente NO.**
*   Qdrant es tu "memoria" interna. Solo n8n (que vive en tu red local) necesita acceder a él.
*   El Dashboard es útil, pero no tiene contraseña por defecto.
*   **Si realmente necesitas acceder desde fuera**: Usa Cloudflare Tunnel pero **ACTIVA Cloudflare Access** (pone una pantalla de login con tu correo) para que nadie más pueda ver o borrar tus datos.

## Seguridad: ¿Cómo ponerle contraseña (API Key)?
Por defecto, en local no tiene contraseña. Si quieres ponerle una:

1.  Edita `docker-compose.windows.yml`.
2.  En el servicio `qdrant`, añade esta variable de entorno:
    ```yaml
    environment:
      - QDRANT__SERVICE__API_KEY=tu_contraseña_secreta
    ```
3.  Reinicia: `docker-compose -f docker-compose.windows.yml up -d`.
4.  Ahora en n8n, tendrás que poner esa contraseña en el campo **API Key**.
