# 🚀 Guía de Despliegue: Cluster K3s (Portal Edition)

Esta guía asume que tienes las 3 VMs encendidas y con SSH accesible.
*   **Srv-Glados** (Master): 2GB RAM.
*   **Srv-Wheatley** (Worker): 2GB RAM.
*   **Srv-PBody** (Worker Heavy): 4GB RAM.

---

## 1. Preparación (En TODOS los nodos)
K3s necesita tráfico fluido. Si usas firewall (UFW) en Ubuntu, desactívalo por ahora para no complicarnos (o abre los puertos 6443 y 10250).

```bash
# En Glados, Wheatley y PBody:
sudo ufw disable
```

---

## 2. Inicializar el Master (Solo en Srv-Glados)
Instalaremos la versión estable.

```bash
# 1. Instalar Master
curl -sfL https://get.k3s.io | sh -

# 2. Obtener el TOKEN del cluster (Lo necesitarás para los workers)
sudo cat /var/lib/rancher/k3s/server/node-token
# (Copia ese churro largo de letras y números)

# 3. Obtener la IP de Glados
ip addr show | grep -i 192.168
# (Anota la IP, ej: 192.168.1.50)
```

**Verificación rápida en Glados:**
`sudo kubectl get nodes` -> Debería salir "Ready" (solo él mismo por ahora).

---

## 3. Unir a los Workers (Wheatley y PBody)
Sustituye `<TU_TOKEN>` y `<IP_GLADOS>` con lo que obtuviste arriba.

> [!IMPORTANT]
> **¿Tailscale IP o Local IP?**
> Aunque tengas Tailscale (IP 100.x.x.x), usa la **IP Local (192.168.x.x)** para el comando `K3S_URL`.
> *   **Razón:** La IP Local es "Hardware Speed" (Bridge). Tailscale añade encriptación y latencia innecesaria para tráfico interno entre VMs que viven juntas.

```bash
# En Srv-Wheatley y Srv-PBody:
curl -sfL https://get.k3s.io | K3S_URL=https://<IP_GLADOS>:6443 K3S_TOKEN=<TU_TOKEN> sh -
```

*Ejemplo real:*
`curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.25:6443 K3S_TOKEN=K10f... sh -`

---

## 4. Etiquetar el Nodo Heavy (Opcional pero Recomendado)
Para que K8s sepa que PBody es el fuerte.
Desde **Glados**:

```bash
# Darle el rol de worker (cosmético)
sudo kubectl label node srv-wheatley node-role.kubernetes.io/worker=worker
sudo kubectl label node srv-pbody node-role.kubernetes.io/worker=worker

# Darle la etiqueta de "Heavy" a PBody
sudo kubectl label node srv-pbody hardware=heavy
```

---

## 5. Verificación Final
Desde **Glados**:
```bash
sudo kubectl get nodes -o wide
```
Deberías ver:
*   `srv-glados` -> Ready (Control Plane)
*   `srv-wheatley` -> Ready
*   `srv-pbody` -> Ready

¡Fellicidades! Tienes un Cluster de Kubernetes real. 🎉
