# ☸️ ¿Por qué Kubernetes? (De Docker a Orquestador)

Actualmente tu flujo es:
1.  **DevContainers:** Entorno de desarrollo aislado y reproducible. (Excelente).
2.  **Docker Compose:** Despliegue de contenedores en una sola máquina. (Excelente para Homelabs sencillos).

Entonces, **¿para qué complicarse la vida con Kubernetes (K8s)?**

## 1. La Diferencia Fundamental: "Mascotas vs Ganado"
*   **Docker Compose (Mascotas):** Si tu servidor `Srv-Glados` muere, tu servicio se cae. Tienes que ir manual, reiniciar, investigar. Cuidas tu servidor con cariño.
*   **Kubernetes (Ganado):** Si `Srv-Glados` muere, Kubernetes se da cuenta en milisegundos y **mueve automáticamente** tus contenedores a `Srv-Wheatley` o `Srv-CaveJohnson`. Tú ni te enteras. Los nodos son reemplazables.

## 2. Lo que K8s te da (que Docker Compose no)
| Característica | Docker Compose | Kubernetes |
| :--- | :--- | :--- |
| **Escalado** | Manual (`up -d --scale 3`). Solo en 1 PC. | Automático (HPA). Si sube la CPU, crea más copias en cualquier nodo disponible. |
| **Updates** | Downtime (Baja el viejo, sube el nuevo). | **Rolling Updates**. Actualiza 1 de 3 replicas a la vez. Cero caída de servicio. |
| **Redes** | Puertos fijos. Conflictos si usas el 80 dos veces. | **Ingress & Services**. Balanceo de carga interno inteligente. |
| **Estado** | "¡Se cayó el contenedor!" (Pánico). | "El estado deseado es 3 copias. Solo veo 2. Creando 1 nueva..." (Paz). |

## 2.5 Nota Técnica: ¿K3s es Kubernetes?
Me preguntaste si usaríamos K3s o K8s.
**Es lo mismo.** K3s es una distribución oficial certificada de Kubernetes (K8s) pero:
*   **K8s "Vanilla":** Es pesado, complejo de instalar, pensado para clusters de 1000 nodos en Google/AWS.
*   **K3s:** Es un solo binario de 50MB. Quita todo el "bloatware" legacy.
*   **¿La API es igual?** 100%. Los comandos `kubectl`, los archivos YAML y Helm funcionan idéntico. **Si aprendes K3s, aprendes K8s.**

### ⚠️ ¿Master en Docker Windows? (Mala Idea)
Preguntaste si podías correr el Master en Docker Desktop (Windows) y unir los Workers VMs.
**No lo hagas.**
*   **Problema de Red:** Docker en Windows corre dentro de una mini-VM oculta (WSL2). Unir eso por red a tus VMs de VirtualBox (Bridged) es una pesadilla de enrutamiento y puertos.
*   **Solución:** Mantén el Master en **Srv-Glados**. Él está en la misma red "física" (Bridged) que los demás. Se verán directo y sin trucos.

## 3. ¿Por qué aprenderlo hoy?
*   **Estándar de Industria:** Hoy en día, "Saber Docker" se asume. "Saber Kubernetes" es lo que diferencia a un Senior. Es el Sistema Operativo de la Nube.
*   **GitOps:** Con herramientas como **ArgoCD**, tu clúster se sincroniza con un repo de GitHub. ¿Haces un commit en el repo? K8s actualiza la app sola. Magia pura.

## 4. Tu Laboratorio (El Plan)
No migraremos *todo* mañana.
*   **Glados (Control Plane):** El cerebro.
*   **Wheatley & Cave (Workers):** El músculo.
*   **Tu Misión:** Desplegar un `nginx` simple y ver cómo, si "matas" a Wheatley (apagas la VM), Glados resucita el nginx en Cave Johnson automáticamente. **Ese momento es el "Click" de K8s.**

## 5. La Verdad para Desarrolladores (¿Mejora mi código?)
Si solo buscas "mejorar tu desarrollo" (escribir código más rápido/limpio), **K8s agrega MUCHA complejidad inicial**.
*   **Docker Compose:** Es simple. `docker-compose up` y a programar.
*   **Kubernetes:** Necesitas `yamls`, `ingress`, `pvcs`, `pods`... para levantar lo mismo.

**¿Cuándo vale la pena para un Dev?**
1.  **Paridad Dev/Prod:** Si en tu trabajo usan K8s, tenerlo en casa hace que entiendas por qué tu código falla en producción (temas de red, permisos, volúmenes) antes de hacer deploy.
2.  **Arquitectura de Microservicios:** Si estás programando una app que tiene 10 microservicios que hablan entre sí, K8s gestiona esa "malla" mucho mejor que Docker Compose.
3.  **Preview Environments:** Puedes configurar (con ArgoCD) que cada vez que hagas una PR en GitHub, se cree un entorno efímero (`pr-123.tudominio.com`) con tu app funcionando para testearla. Eso es nivel Dios.

**Veredicto:**
*   Para *aprender cómo funciona el mundo cloud*: **SÍ**.
*   Para *programar tu web personal*: **NO (Overkill)**.
*   Para *tu Homelab*: **SÍ (Por diversión y resiliencia)**.

## 6. ¿DevContainers en Kubernetes? (La Frontera Final)
Me preguntaste si puedes mover tu entorno de desarrollo al clúster.
La respuesta corta es: **SÍ, y es el futuro.**

Pero no se hace "a pelo". Usarías herramientas como:
1.  **Coder (Self-Hosted):** Despliegas Coder en tu clúster. Entras a una web, le das a "Crear Workspace", y Coder levanta un Pod en Kubernetes que **ES** tu DevContainer. Te conectas con VS Code remoto y programas con la potencia de tu servidor, no de tu laptop.
2.  **DevSpace / Tilt:** Para desarrollo híbrido (parte en local, parte en el clúster).

**Nivel de Dificultad:** Alto al principio, pero una vez montado (Coder), es tan fácil como abrir el navegador. ¡Podríamos intentarlo en el futuro!

### 🆚 Coder: ¿Docker vs Kubernetes?
Ya probaste Coder en Docker y no te convenció. **En Kubernetes es MUCHO mejor.**
*   **El problema en Docker:** Usar Docker dentro de Docker (DinD) es lento, complejo y da errores de permisos.
*   **La ventaja en K8s:** Kubernetes gestiona los pods de forma nativa. Cada workspace es un Pod aislado real, con su propia CPU/RAM garantizada. Es más estable, más rápido y se siente como una máquina virtual real, no un hack.

**¿Dónde corre y cuánto cuesta?**
*   **Alojamiento:** Corre DENTRO de tu clúster (en `Srv-Glados` o `Srv-CaveJohnson`). Tú eres el dueño de la nube.
*   **Precio:** **GRATIS.** Usaremos la versión *Open Source (Community)* de Coder.
*   **Recursos:** Consume la RAM de tu PC. Si asignas 4GB a tu workspace, se restan de los 32GB de tu Ryzen. ¡Cero costos mensuales!

**¿Coder creando VMs (VirtualBox) o Pods (K8s)?**
*   **Coder + VirtualBox:** Sería muy pesado. Imagina esperar 5 min a que arranque Windows cada vez que quieres programar. Y gastarías 40GB de disco por proyecto.
*   **Coder + K8s (Pods):** Es el punto dulce.
    *   Arranca en 5 segundos.
    *   Se "siente" como una VM (tienes root, instalas lo que quieras).
    *   Gasta lo mismo que Docker.
    *   **Conclusión:** Un Pod de K8s bien configurado (Sysbox/Privileged) es indistinguible de una VM para desarrollo, pero 100 veces más rápido.

## 7. Estrategia de Hardware: ¿Melón o Sandía?
Pregunta del millón: **¿Mejor tener 2 Nodos Gordos (4vCPU/4GB) o 4 Nodos Pequeños (2vCPU/2GB)?**

Para **Elasticsearch, Grafana o Java**, la respuesta es **MIXTA**.
1.  **Apps "Tragonas" de RAM (Elasticsearch):** Necesitan mucha RAM en *un solo bloque*. Si le das 2GB, explotan (OOM Kill).
2.  **Apps "Web" (Nginx, Nodejs, Go):** Prefieren distribucirse en muchos nodos pequeños para que si uno cae, los otros sigan.

**Tu Estrategia Ganadora (Plan Homelab):**
No hagas todos iguales. Crea roles.
*   **Srv-Glados (Master):** 2GB (Cerebro).
*   **Srv-Wheatley (Worker General):** 2GB (Para apps ligeras).
*   **Srv-PBody (Worker "Heavy"):** **Súbele a 4GB/4vCPU.**
    *   *Truco de K8s:* Usarás `NodeAffinity` para decirle a Elastic: *"Tú solo corre en PBody, que es el fuerte"*.
    *   Así aprendes conceptos avanzados de K8s (Scheduling) y optimizas recursos.

**Veredicto:** Sí, K8s es **IDEAL** para Elastic/Grafana. De hecho, se instalan con un solo comando (`helm install kube-prometheus-stack`) y te montan todo el sistema de monitorización solo en 2 minutos.

## 8. Desarrollo Híbrido: Tilt y DevSpace
Preguntaste por ellos. Son herramientas de "Inner Loop" (Ciclo Rápido).
*   **El Problema:** Programar en K8s manual es lento (Escribir código -> `docker build` -> `docker push` -> `kubectl apply` -> esperar...).
*   **La Solución (Tilt/DevSpace):** Tú le das a `Save` en VS Code, y ellos detectan el cambio, inyectan el código nuevo en el contenedor corriendo en el clúster (Hot Reload) en milisegundos.

**¿Cuál usar?**
*   **Tilt:** Tiene una interfaz web preciosa que te muestra logs y errores en tiempo real. Es el favorito para equipos grandes.
*   **Veredicto:** Para tu Homelab, **Tilt** es una joya visual. Ver cómo tus microservicios se ponen verdes en su dashboard es adictivo.

## 9. El Stack Definitivo (La Sinergia)
Para responder a tu duda final: **SE COMPLEMENTAN.**

Imagínate el flujo de trabajo de un dios del código:
1.  **Infraestructura:** K3s corriendo en tu cluster (Glados/Wheatley/Cave).
2.  **Entorno (Donde estás):** Entras a **Coder** desde tu iPad. Coder te da una terminal en la nube con 4GB de RAM.
3.  **Workflow (Qué haces):** En esa terminal de Coder, ejecutas `tilt up`.
4.  **Resultado:** Tilt levanta tu app en el clúster y vigila tus cambios.

Tú escribes código en Coder -> Tilt lo detecta -> Tu app se actualiza en el clúster.
**Es el Santo Grial.** No usas tu PC para nada, todo ocurre en el servidor.

## 10. ¿Y cómo veo mi clúster K8s?
Me preguntaste por Portainer. ¡Buenas noticias!
1.  **Portainer:** Sí, Portainer gestiona Kubernetes perfectamente.
    *   Puedes conectarlo a tu clúster K3s y ver Pods, Logs y Volúmenes igual que ves tus contenedores Docker hoy. Es tu opción "familiar".
2.  **OpenLens (Recomendado para Devs):** Es una app de escritorio (Windows/Mac).
    *   Te conectas al clúster y es visualmente increíble. Te sientes como un operador de Matrix.
3.  **Grafana + Prometheus:** Lo que pondremos en **Srv-PBody**.
    *   Esto no es para "gestionar" (borrar pods), sino para "monitorizar" (Gráficas bonitas de CPU, RAM, Red).
    *   Es el estándar de la industria.

**Resumen:** Usa **Portainer** para empezar, **Lens** para sentirte Pro, y **Grafana** para presumir de gráficas.
