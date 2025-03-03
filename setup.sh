#!/bin/bash
# Installer untuk Minecraft Port Forwarding
# - rinetd akan menangani forwarding untuk Minecraft Java (TCP)
# - iptables akan menangani forwarding untuk Minecraft Bedrock (UDP)

# Pastikan script dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
    echo "Jalankan script ini sebagai root!"
    exit 1
fi

echo "=== Minecraft Port Forwarding Installer ==="
echo "Pastikan VPS terhubung ke internet."
echo ""

# Minta input IP Server Tujuan (wajib)
read -p "Masukkan IP Server Tujuan: " TARGET_SERVER
if [[ -z "$TARGET_SERVER" ]]; then
    echo "Error: Server tujuan harus diinput!"
    exit 1
fi

# Minta input port untuk Minecraft Java (TCP)
read -p "Masukkan port untuk Minecraft Java (default: 25565): " JAVA_PORT
JAVA_PORT=${JAVA_PORT:-25565}

# Minta input port untuk Minecraft Bedrock (UDP)
read -p "Masukkan port untuk Minecraft Bedrock (default: 19132): " BEDROCK_PORT
BEDROCK_PORT=${BEDROCK_PORT:-19132}

echo ""
echo "Port yang dipilih: Java = $JAVA_PORT, Bedrock = $BEDROCK_PORT"
echo "Server Tujuan: $TARGET_SERVER"
echo ""

echo "Mengupdate package dan menginstall rinetd..."
apt-get update
apt-get install -y rinetd

echo "Mengonfigurasi rinetd untuk Minecraft Java..."
RINETD_CONF="/etc/rinetd.conf"
if [ -f "$RINETD_CONF" ]; then
    cp "$RINETD_CONF" "${RINETD_CONF}.bak"
    echo "Backup konfigurasi rinetd lama telah dibuat: ${RINETD_CONF}.bak"
fi

cat <<EOF > $RINETD_CONF
# Forward Minecraft Java traffic dari VPS ke server tujuan
0.0.0.0 $JAVA_PORT $TARGET_SERVER $JAVA_PORT
EOF

echo "Restarting rinetd service..."
systemctl restart rinetd
systemctl enable rinetd

echo "Mengaktifkan IP forwarding..."
sysctl -w net.ipv4.ip_forward=1

echo "Mengonfigurasi iptables untuk forwarding UDP Minecraft Bedrock..."
iptables -t nat -A PREROUTING -p udp --dport $BEDROCK_PORT -j DNAT --to-destination $TARGET_SERVER:$BEDROCK_PORT
iptables -t nat -A POSTROUTING -p udp -d $TARGET_SERVER --dport $BEDROCK_PORT -j MASQUERADE

echo "Menginstall iptables-persistent untuk menyimpan aturan iptables secara persisten..."
apt-get install -y iptables-persistent

echo "Menyimpan aturan iptables..."
netfilter-persistent save

echo ""
echo "=== Instalasi Selesai ==="
echo "Minecraft Java (TCP) akan diforward melalui rinetd pada port $JAVA_PORT."
echo "Minecraft Bedrock (UDP) akan diforward melalui iptables pada port $BEDROCK_PORT."
echo "Server Tujuan: $TARGET_SERVER."
echo "Pastikan firewall mengizinkan trafik pada port-port tersebut."
