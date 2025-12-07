# 🛠️ Plan Maestro: Homelab Híbrido (IA + Virtualización)

## 🧠 Contexto y Estrategia
El objetivo es crear un entorno de **Sandboxes (Cajas de Arena)** aisladas para pruebas destructivas, hacking ético, y aprendizaje de Linux, sin sacrificar el rendimiento de la estación de trabajo principal que corre modelos de Inteligencia Artificial.

### 1. Gestión de Recursos (Hardware Real: Ryzen 9 5900X)
*   **CPU (12 Cores / 24 Threads):** Tenemos potencia de sobra. Asignaremos 2-4 vCPUs por máquina virtual sin miedo.
*   **RAM (32GB Total):** Es el recurso crítico.
    *   ~6GB para Windows (Host).
    *   ~10GB reservados para desbordamiento de LLMs (Modelos 14b/70b cuantizados).
    *   **~16GB libres para VMs:** Presupuesto para ejecutar múltiples laboratorios simultáneos.
*   **Almacenamiento (Jerarquía de Velocidad):**
    *   🟢 **NVMe (C: - Samsung 970 EVO - 500GB):** Exclusivo para Windows y Modelos LLM (Máxima velocidad de carga en VRAM).
    *   🟡 **SSD SATA (D/E: - Samsung 870 EVO - 500GB):** Exclusivo para **alojar las VMs (Archivos .vdi)**. (Velocidad necesaria para que el SO invitado sea fluido).
    *   🔴 **HDD (D/E: - Seagate 3TB):** Exclusivo para guardar (Cold Storage) los **archivos ISO** de instalación y Backups (Snapshots exportados).

### 2. Inventario de VMs Recomendado (Top 5)

Aquí tienes la lista maestra de las 5 máquinas que conformarán tu laboratorio, con sus usuarios y propósitos definidos.

| Nombre Servidor | Usuario | Descripción / Propósito | Recursos |
| :--- | :--- | :--- | :--- |
| **Srv-Glados** | `chell` | **K8s Master / Main**. Servidor principal y Control Plane de Kubernetes (K3s). | 2 vCPU / 2 GB (**50GB Disk**) |
| **Srv-Wheatley** | `ratman` | **K8s Worker 01 / Test**. Nodo para pruebas destructivas. Si explota, no importa. | 2 vCPU / 2 GB (**50GB Disk**) |
| **Srv-PBody** | `orange` | **K8s Worker 02 / Heavy**. Nodo potente para Elastic/Grafana/Java. | 4 vCPU / 4 GB (**50GB Disk**) |
| **Srv-CaveJohnson** | `cave` | **Reserva / Alpha**. Servidor experimental para software inestable. | 2 vCPU / 2 GB (**50GB Disk**) |
| **Srv-Atlas** | `blue` | **Reserva**. Androide de pruebas para expandir el clúster. | 2 vCPU / 2 GB (**50GB Disk**) |
| **Sandbox-Kali** | `mrrobot` | **"Hack the Planet"**. Suite de seguridad Ofensiva/Defensiva para auditorías y pentesting. | 2 vCPU / 4 GB / **128MB Video** |

### 🔬 Escenario Especial: Laboratorio Kubernetes (K3s)
¡Buena idea reutilizar recursos! Convertiremos tus servidores actuales en un Clúster:
*   **Master Node:** `Srv-Glados` (Controla el clúster + corre servicios estables).
*   **Worker Node (Light):** `Srv-Wheatley` (Webs, APIs ligeras).
*   **Worker Node (Heavy):** `Srv-PBody` (Elasticsearch, Bases de Datos, Coder).
*   **Ventaja:** Tienes un clúster heterogéneo (Hybrid) real. Glados manda, PBody carga peso.

### 3. Aislamiento y Red
*   **Virtualizador:** VirtualBox 7.x (Aislamiento total).
*   **Modo de Red:** **Bridged (Adaptador Puente)**.
    *   *Efecto:* Las VMs obtendrán su propia IP `192.168.x.x` del router de tu casa.
    *   *Ventaja:* Acceso SSH directo desde tu terminal de Windows normal, como si fueran servidores físicos reales.

---

## 🚀 Guía de Ejecución

### Fase 1: Preparación (BIOS y Descargas)
1.  **BIOS:** Asegura que **SVM Mode** (Virtualización AMD) esté `ENABLED` en tu BIOS.
2.  **Descargas (Guardar en HDD):**
    *   [VirtualBox 7.x](https://www.virtualbox.org/wiki/Downloads) (Windows hosts).
    *   **IMPORTANTE:** [VirtualBox Oracle VM VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads) (Misma versión exacta).
    *   ISOs: Omarchy, Kali, Ubuntu Server.

### Fase 2: Instalación Correcta
1.  Instala VirtualBox estándar en C:.
2.  Ejecuta el **Extension Pack** para instalar los drivers de USB 3.0 y NVMe virtuales.
3.  **🔴 CONFIGURACIÓN CRÍTICA (Hacer esto ANTES de crear nada):**
    *   Abre VirtualBox.
    *   Ve a `Archivo` > `Preferencias` > `General`.
    *   **Carpeta predeterminada de máquinas:** Cambia esto a una carpeta en tu **SSD SATA (Samsung 870)**. Ej: `D:\VirtualBox_VMs`.
    *   *Por qué:* Si no haces esto, por defecto se crean en C: y llenarán tu NVMe rapidísimo.

### Fase 3: Creación de "Srv-Glados" (Ejemplo)
1.  **Nueva Máquina:**
    *   Nombre: `Srv-Glados`
    *   Imagen ISO: Selecciónala desde tu HDD.
    *   Tipo: Linux / Ubuntu (64-bit).
    *   *Omitir instalación desatendida:* **MARCAR** (Para instalar manual y aprender).
2.  **Hardware:**
    *   3072 MB RAM (3GB) o 2048 MB (2GB).
    *   2 CPUs.
    *   **EFI:** Habilitar si es un OS moderno (Ubuntu 24.04 lo prefiere), pero para servidores a veces Legacy BIOS es menos problemático. Prueba primero sin EFI especial.
3.  **Disco Duro:**
    *   Tamaño: **50 GB**. (Recomendado estándar).
    *   **IMPORTANTE:** Pre-reservar espacio completo: **DESMARCADO** (Queremos que crezca dinámicamente).

### Fase 4: Ajustes de Red (Antes de Arrancar)
1.  Click derecho en `Srv-Glados` > **Configuración**.
2.  **Red:**
    *   Conectado a: Cambiar "NAT" a **Adaptador Puente**.
    *   Nombre: Selecciona tu controlador Ethernet o WiFi real.
    *   *Modo Promiscuo:* Permitir todo (A veces necesario para ver otras VMs).

### Fase 5: Estrategia de Snapshots (Guardar y Restaurar)
Los **Snapshots** son tu "punto de guardado" (como en los videojuegos). Es vital crear uno base antes de empezar a usar la máquina.

**1. Cómo Crear el "Punto Base" (Imagen Limpia):**
*   Asegúrate de que la VM tenga todo lo básico: `sudo apt update && sudo apt upgrade -y`, Tailscale instalado y funcionando.
*   **APAGA** la máquina virtual (Power Off).
*   En VirtualBox, selecciona la máquina > Click en el icono de lista (burguer menu) al lado de su nombre > **Instantáneas (Snapshots)**.
*   Click en **Tomar (Take)** (el icono de la cámara 📷).
*   **Nombre:** `Base - Clean Install`.
*   **Descripción:** "Ubuntu actualizado + Tailscale listo. Sin Docker aún."

**2. Cómo Restaurar (Volver al pasado):**
*   Si rompes el servidor o quieres empezar de cero.
*   Apaga la máquina.
*   Ve a la pestaña de **Instantáneas**.
*   Selecciona `Base - Clean Install` y dale a **Restaurar (Restore)** (el icono de la flecha hacia arriba ⬆️).
*   ¡En 5 segundos tu máquina está como nueva!

**3. Recomendación de Flujo:**
*   Crea un snapshot `Base` (Limpio).
*   Crea un snapshot `Docker Ready` (Con Docker instalado).
*   Trabaja siempre sobre el último. Si fallas, retrocede un paso, no al principio.

### 💡 Tip Pro: Modo "Headless" (Sin Pantalla)
Para que tus servidores funcionen en segundo plano sin tener la ventana de VirtualBox abierta ocupando espacio:
1.  En la lista de VMs, haz click derecho sobre la máquina.
2.  Ve a **Inicio** > **Inicio Desacoplado** (Headless Start).
3.  La máquina arrancará en "background" (no verás ventana).
4.  Podrás conectarte por SSH/Tailscale normalmente.
5.  Para apagarla: Click derecho > Cerrar > ACPI Shutdown.

### 🔧 Mantenimiento: ¿Cómo aumentar disco de 25GB a 50GB?
Si ya creaste la máquina y se te quedó corta, **no la borres**. Se puede expandir:
1.  **En VirtualBox (Host):**
    *   Apaga la VM.
    *   Ve a `Archivo` > `Herramientas` > `Administrador de Medios Virtuales`.
    *   Busca el disco de `Srv-Glados.vdi`, usa el deslizador para subirlo a **50 GB** y dale a "Aplicar".
2.  **En Linux (Guest):**
    *   Arranca la VM. Linux verá el espacio físico pero no lo usará aún.
    *   Ejecuta: `sudo growpart /dev/sda 3` (Para extender la partición LVM, suele ser la 3).
    *   Ejecuta: `sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv` (Para extender el volumen lógico).
    *   Ejecuta: `sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv` (Para extender el sistema de archivos).
    *   *Nota: Los nombres de partición pueden variar, usa `lsblk` para verificar.*

    *   *Nota: Los nombres de partición pueden variar, usa `lsblk` para verificar.*

## 10. Gestión Centralizada: Portainer Agent
Me preguntaste si deberías agregar algo a Portainer. **SÍ: El Agente.**

## 10. Gestión Visual y Monitorización
Me preguntaste por Portainer.
**¿Instalar Docker + Portainer Agent en los nodos K8s?**
**NO RECOMENDADO.** K3s ya trae su propio "motor" (Containerd). Instalar Docker encima es duplicar procesos y gastar RAM a lo tonto.

**Mejor Estrategia: Portainer Agent (Versión K8s Nativa)**
Si Portainer te pide Agente, se lo daremos... ¡pero como un Pod de Kubernetes! (Sin instalar Docker extra).

**Pasos:**
1.  **En Glados (Terminal):**
    Despliega el agente oficial para K8s:
    ```bash
    curl -L https://downloads.portainer.io/ce2-21/portainer-agent-k8s-nodeport.yaml -o portainer-agent-k8s.yaml
    sudo kubectl apply -f portainer-agent-k8s.yaml
    ```
2.  **En Portainer (Tu PC):**
    *   Ve a `Environments` > `Add environment`.
    *   Selecciona **Kubernetes** > **Agent**.
    *   **Name:** `Homelab-K3s`.
    *   **Environment URL:** `192.168.68.66:30778` (La IP de Glados y el puerto NodePort estándar del agente).
    *   Dale a **Connect**.

¡Y ya! El agente correrá dentro del clúster consumiendo recursos mínimos, y tendrás control total.

    *   Dale a **Connect**.

¡Y ya! El agente correrá dentro del clúster consumiendo recursos mínimos, y tendrás control total.

## 10.5 Alternativa Visual: OpenLens (Opcional Desktop)
Si prefieres una app nativa en tu Mac:
*   Instala **OpenLens**.
*   Carga el `kubeconfig` de Glados.

## 10.6 La Solución Web Definitiva: Tu Portainer Actual
Como buscas una solución **100% Web** (sin instalar nada en tu Mac), **Portainer es el ganador.**

**Por qué:**
1.  **Centralizado:** Ya lo tienes corriendo en Windows.
2.  **Accesible:** Entras desde Chrome en tu Mac (`http://ip-windows:9000`).
3.  **Híbrido:** Ves tus contenedores Docker viejos Y tus nuevos Pods de K3s en la misma pestaña.

**Pasos para activarlo (Recap):**
1.  En **Glados**, despliega el Agente K8s (ver arriba).
2.  En **Portainer**, conecta al agente (`192.168.68.66:30778`).
3.  ¡Listo! Desde tu Mac, abre Portainer y gestiona todo.

Verás tus Pods, Logs y Terminales con una interfaz de lujo. Es lo que usan los profesionales.

## 10.6 Monitorización desde Mac (Tu Daily Driver)
Como usas Mac a diario y Windows es solo el "sótano":

**Opción A: OpenLens en Mac (La mejor)**
1.  Instala **OpenLens** en tu Mac.
2.  Copia el `kubeconfig` de Glados.
3.  **Truco:** Cambia la IP por la **IP de Tailscale de Glados** (`100.x.y.z`) o su nombre MagicDNS (`srv-glados`).
4.  Al guardar, tu Mac se conectará directo al clúster vía VPN. Tendrás control total remoto.

**Opción B: Tu Homepage (Vistazo Rápido)**
Como ya tienes Homepage en Windows, agrégale el widget de Kubernetes para ver si los nodos están vivos desde tu Mac (abriendo la web de Homepage).

En tu `services.yaml` de Homepage:
```yaml
- Kubernetes: # (Nombre del grupo)
    - Cluster K3s:
        icon: kubernetes.png
        widget:
            type: kubernetes
            url: https://192.168.68.66:6443 # IP Local de Glados
            key: /app/config/kubeconfig # Tienes que montar el archivo dentro del container
```
*Requiere montar el archivo `k3s.yaml` dentro del contenedor de Homepage.*

### Fase 6: 🌐 Salida a Internet (Tailscale)
Para acceder a tus máquinas desde fuera (SSH) de forma segura y sin abrir puertos, usaremos **Tailscale**. Es una VPN "Mesh" que conecta tus dispositivos como si estuvieran en la misma red WiFi.

1.  **En la VM (Glados):**
    *   Ejecuta: `curl -fsSL https://tailscale.com/install.sh | sh`
    *   Inicia: `sudo tailscale up`
    *   Copia el link que te da y autorízalo con tu Google/GitHub.
2.  **En tu Cliente (Mac/PC/iPhone):**
    *   Instala la app de **Tailscale**.
    *   Loguéate con la misma cuenta.
3.  **Acceso Mágico:**
    *   Ahora puedes hacer SSH usando el nombre directo: `ssh chell@srv-glados`
    *   ¡Funciona desde cualquier lugar del mundo!
