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
| **Srv-Glados** | `chell` | **K8s Master / Main**. Servidor principal y Control Plane de Kubernetes (K3s). | 2 vCPU / 2 GB |
| **Srv-Wheatley** | `ratman` | **K8s Worker 01 / Test**. Nodo para pruebas destructivas. Si explota, no importa. | 2 vCPU / 2 GB |
| **Srv-CaveJohnson** | `cave` | **K8s Worker 02 / Alpha**. Nodo adicional para Alta Disponibilidad (HA). | 2 vCPU / 2 GB |
| **Srv-Atlas** | `blue` | **Reserva / Worker 03**. Androide de pruebas para expandir el clúster. | 2 vCPU / 2 GB |
| **Srv-PBody** | `orange` | **Reserva / Worker 04**. Androide de pruebas para expandir el clúster. | 2 vCPU / 2 GB |
| **Sandbox-Kali** | `mrrobot` | **"Hack the Planet"**. Suite de seguridad Ofensiva/Defensiva para auditorías y pentesting. | 2 vCPU / 4 GB / **128MB Video** |

### 🔬 Escenario Especial: Laboratorio Kubernetes (K3s)
¡Buena idea reutilizar recursos! Convertiremos tus servidores actuales en un Clúster:
*   **Master Node:** `Srv-Glados` (Controla el clúster + corre servicios estables).
*   **Worker Nodes:** `Srv-Wheatley` + `Srv-CaveJohnson` (Hacen el trabajo sucio).
*   **Ventaja:** No creas VMs nuevas innecesariamente. Glados ya tiene Docker, y K3s convive bien con él (o lo reemplaza).

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
    *   Tamaño: 25 GB.
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
