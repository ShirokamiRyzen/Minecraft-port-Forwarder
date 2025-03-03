# Minecraft Port Forwarder Installer

Script ini akan menginstall dan mengonfigurasi port forwarder untuk server Minecraft kamu:
- **Minecraft Java (TCP)** akan diforward melalui **rinetd**.
- **Minecraft Bedrock (UDP)** akan diforward melalui **iptables**.

## Prasyarat

- VPS dengan distribusi Linux berbasis Debian (misalnya Debian, Ubuntu)
- Akses root (atau gunakan `sudo`)
- Koneksi internet
- **IP Server Tujuan (target server)** untuk Minecraft (wajib diisi)

## Install

Jalankan perintah berikut di terminal VPS kamu:

```bash
curl -o setup.sh https://raw.githubusercontent.com/ShirokamiRyzen/Minecraft-port-Forwarder/refs/heads/main/setup.sh && chmod +x setup.sh && sudo ./setup.sh
```

## Uninstall

Jalankan perintah berikut di terminal VPS kamu:

```bash
curl -o uninstall.sh https://raw.githubusercontent.com/ShirokamiRyzen/Minecraft-port-Forwarder/refs/heads/main/uninstall.sh && chmod +x uninstall.sh && sudo ./uninstall.sh
```
