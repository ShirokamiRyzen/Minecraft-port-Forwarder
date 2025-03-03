#!/bin/bash
# Installer untuk Minecraft Port Forwarding
# - rinetd akan menangani forwarding untuk Minecraft Java (TCP)
# - socat akan menangani forwarding untuk Minecraft Bedrock (UDP)
#   melalui systemd dengan KillMode=control-group

if [[ $EUID -ne 0 ]]; then
    echo "Jalankan script ini sebagai root!"
    exit 1
fi

echo "=== Minecraft Port Forwarding Installer ==="
echo "Pastikan VPS terhubung ke internet."
echo ""

read -p "Masukkan IP Server Tujuan: " TARGET_SERVER
if [[ -z "$TARGET_SERVER" ]]; then
    echo "Error: Server tujuan harus diinput!"
    exit 1
fi

read -p "Masukkan port untuk Minecraft Java (default: 25565): " JAVA_PORT
JAVA_PORT=${JAVA_PORT:-25565}

read -p "Masukkan port untuk Minecraft Bedrock (default: 19132): " BEDROCK_PORT
BEDROCK_PORT=${BEDROCK_PORT:-19132}

echo ""
echo "Port yang dipilih: Java = $JAVA_PORT, Bedrock = $BEDROCK_PORT"
echo "Server Tujuan: $TARGET_SERVER"
echo ""

echo "Mengupdate package dan menginstall rinetd serta socat..."
apt-get update
apt-get install -y rinetd socat

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

echo "Membuat systemd service untuk socat (Bedrock UDP forwarding)..."
SOCAT_SERVICE="/etc/systemd/system/socat-bedrock.service"
cat <<EOF > $SOCAT_SERVICE
[Unit]
Description=Socat Bedrock UDP Forwarder
After=network.target

[Service]
ExecStart=/usr/bin/socat UDP-RECVFROM:$BEDROCK_PORT,reuseaddr,fork UDP-SENDTO:$TARGET_SERVER:$BEDROCK_PORT
Restart=always
RestartSec=10
KillMode=control-group

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan enable service socat-bedrock
echo "Reloading systemd dan mengaktifkan service socat-bedrock..."
systemctl daemon-reload
systemctl enable socat-bedrock.service
systemctl start socat-bedrock.service

echo ""
echo "=== Instalasi Selesai ==="
echo "Minecraft Java (TCP) akan diforward melalui rinetd pada port $JAVA_PORT."
echo "Minecraft Bedrock (UDP) akan diforward melalui socat (systemd service) pada port $BEDROCK_PORT."
echo "Server Tujuan: $TARGET_SERVER."
echo "Pastikan firewall mengizinkan trafik pada port-port tersebut."
