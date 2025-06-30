# container_ssh

A lightweight solution for toggling network access to a container via host firewall rules. This is particularly useful because neither Docker nor Podman support modifying port forwarding on a running container.

---

## ❗ Why This Project?

- **Port bindings (`-p`) are immutable after container start.**
  - 🔗 Podman issue: https://github.com/containers/podman/issues/18309  
  - 🔗 Docker discussion: https://forums.docker.com/t/how-to-expose-port-on-running-container/3252/12

- Instead of restarting the container, we **control network access to port `2222` using host firewall rules**.

- This allows toggling SSH accessibility dynamically without touching the container.

---

## 🧰 Files Overview

- `Dockerfile`: Builds an OpenSSH-enabled container with an `operator` user.
- `docker-compose.yml`: Maps host port `2222` to container port `22`.
- `toggle_ssh.sh`: Adds or removes firewall rules to allow or block SSH access.
- `id_rsa.pub`: Public SSH key authorized inside the container.

---
## 🚀 Quick Start

### 1. Build & Start the Container
```
docker-compose up -d

# OR
podman-compse up -d

```
### 2. Connect via SSH

```
ssh -i ~/.ssh/id_rsa operator@localhost -p 2222
```
Note: Your private key ~/.ssh/id_rsa should match the id_rsa.pub included in the repo.

### 3. Use toggle_ssh.sh to control the access to host port 2222


```bash
./toggle_ssh.sh enable     # enable ssh to port 2222
./toggle_ssh.sh disable    # disbale ssh to port 2222
./toggle_ssh.sh status     # Check if the status of port 2222
```