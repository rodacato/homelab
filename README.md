# My Homelab

Repositorio de configuración para infraestructura local (Homelab) utilizando Docker y Cloudflare Tunnel.

El objetivo de este proyecto es tener servicios autohospedados accesibles de forma segura desde internet sin exponer puertos del router, comenzando con automatización (n8n) y preparado para escalar a IA local.

## Servicios Soportados

| Servicio | Estado | URL Local | Acceso Público |
|----------|--------|-----------|----------------|
| **n8n** | ✅ Activo | `http://localhost:5678` | Vía Cloudflare Tunnel |
| **Cloudflare Tunnel** | ✅ Activo | N/A | Gestiona la conexión segura |
| **LLM Studio / MCP** | 🚧 Planeado | - | - |

## Documentación

Hemos creado guías detalladas para la configuración y mantenimiento:

*   📄 **[Guía de Configuración n8n + Cloudflare](./docs/n8n-setup-guide.md)**: Instrucciones paso a paso para configurar el túnel, el dominio y solucionar problemas comunes (Troubleshooting).

## Inicio Rápido

1.  **Clonar repositorio:**
    ```bash
    git clone <repo-url>
    cd homelab
    ```

2.  **Configuración:**
    Copia el archivo de ejemplo y configura tus secretos (Token de Cloudflare y Dominio).
    ```bash
    cp .env.example .env
    ```

3.  **Ejecutar:**
    ```bash
    docker-compose up -d
    ```

Para más detalles sobre cómo obtener el token y configurar el dominio, consulta la [guía de configuración](./docs/n8n-setup-guide.md).
