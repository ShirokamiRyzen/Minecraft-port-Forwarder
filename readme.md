# Minecraft Port Forwarder Installer

Script ini akan menginstall dan mengkonfigurasi port forwarder untuk server Minecraft kamu:
- **Minecraft Java (TCP)** akan diteruskan menggunakan **rinetd**.
- **Minecraft Bedrock (UDP)** akan diteruskan menggunakan **socat** yang dijalankan sebagai systemd service (dengan opsi `KillMode=control-group`).

## Prasyarat

- VPS dengan distribusi Linux berbasis Debian (misalnya Debian, Ubuntu)
- Akses root (atau gunakan `sudo`)
- Koneksi internet
- IP Server Tujuan (target server) untuk Minecraft

## Install

Jalankan perintah berikut di terminal VPS kamu:

```bash
curl -o setup.sh https://raw.githubusercontent.com/ShirokamiRyzen/Minecraft-port-Forwarder/refs/heads/main/setup.sh && chmod +x setup.sh && sudo ./setup.sh
```

## Uninstall

Jalankan perintah berikut di terminal VPS kamu:

```bash
curl -o setup.sh https://raw.githubusercontent.com/ShirokamiRyzen/Minecraft-port-Forwarder/refs/heads/main/setup.sh && chmod +x setup.sh && sudo ./setup.sh
```
