#!/bin/bash
# Uninstaller untuk Minecraft Port Forwarder
# Script ini akan:
# - Menghapus aturan iptables untuk forwarding UDP Minecraft Bedrock
# - Mengembalikan konfigurasi rinetd ke backup (jika tersedia)

# Pastikan script dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
    echo "Jalankan script ini sebagai root!"
    exit 1
fi

echo "=== Uninstall Minecraft Port Forwarder ==="
echo ""

# Minta input IP Server Tujuan yang digunakan saat instalasi
read -p "Masukkan IP Server Tujuan yang digunakan saat instalasi: " TARGET_SERVER
if [[ -z "$TARGET_SERVER" ]]; then
    echo "Error: Server tujuan harus diinput!"
    exit 1
fi

# Minta input port untuk Minecraft Bedrock (UDP)
read -p "Masukkan port untuk Minecraft Bedrock (default: 19132): " BEDROCK_PORT
BEDROCK_PORT=${BEDROCK_PORT:-19132}

echo ""
echo "Menghapus aturan iptables untuk UDP Bedrock..."
iptables -t nat -D PREROUTING -p udp --dport $BEDROCK_PORT -j DNAT --to-destination $TARGET_SERVER:$BEDROCK_PORT
iptables -t nat -D POSTROUTING -p udp -d $TARGET_SERVER --dport $BEDROCK_PORT -j MASQUERADE

echo "Menyimpan aturan iptables yang telah diperbarui..."
netfilter-persistent save

echo ""
RINETD_CONF="/etc/rinetd.conf"
BACKUP_CONF="/etc/rinetd.conf.bak"
if [ -f "$BACKUP_CONF" ]; then
    echo "Mengembalikan konfigurasi rinetd dari backup..."
    cp "$BACKUP_CONF" "$RINETD_CONF"
    rm -f "$BACKUP_CONF"
    systemctl restart rinetd
    echo "Konfigurasi rinetd telah dikembalikan."
else
    echo "Tidak ditemukan backup konfigurasi rinetd. Konfigurasi tidak diubah."
fi

echo ""
echo "=== Uninstall Selesai ==="
echo "Minecraft Port Forwarder telah dihapus."
