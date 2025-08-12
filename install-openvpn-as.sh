#!/bin/bash
# Instalador OpenVPN-AS con Podman + systemd
# Probado en AlmaLinux 9

set -e

CONTAINER_NAME="openvpn-as"
DATA_DIR="/opt/openvpn/data"
HOSTNAME_FQDN="gssmh.ddns.net"
ADMIN_USER="openvpn"
ADMIN_PASS="R00tu53r"

echo "[+] Creando carpeta de datos..."
sudo mkdir -p "${DATA_DIR}"
sudo chown -R root:root "${DATA_DIR}"

# 1. Crear contenedor si no existe
if ! podman ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "[+] Creando contenedor ${CONTAINER_NAME}..."
    podman run -d \
        --name="${CONTAINER_NAME}" \
        --device /dev/net/tun \
        --cap-add=MKNOD --cap-add=NET_ADMIN \
        -p 944:944 \
        -p 4344:4344 \
        -p 1195:1195/udp \
        -v "${DATA_DIR}":/openvpn \
        --restart=unless-stopped \
        --hostname="${HOSTNAME_FQDN}" \
        openvpn/openvpn-as
else
    echo "[!] El contenedor ${CONTAINER_NAME} ya existe. Saltando creación."
fi

sleep 10

# 2. Configuración interna de OpenVPN-AS
echo "[+] Configurando OpenVPN-AS..."
podman exec "${CONTAINER_NAME}" /usr/sbin/sacli --user "${ADMIN_USER}" --new_pass "${ADMIN_PASS}" SetLocalPassword
podman exec "${CONTAINER_NAME}" /usr/sbin/sacli --key "admin_ui.https.port"        --value "944"  ConfigPut
podman exec "${CONTAINER_NAME}" /usr/sbin/sacli --key "cs.https.port"              --value "944"  ConfigPut
podman exec "${CONTAINER_NAME}" /usr/sbin/sacli --key "vpn.server.daemon.tcp.port" --value "4334" ConfigPut
podman exec "${CONTAINER_NAME}" /usr/sbin/sacli --key "vpn.server.daemon.udp.port" --value "1195" ConfigPut
podman exec "${CONTAINER_NAME}" /usr/sbin/sacli --key "vpn.daemon.0.listen.port"   --value "1195" ConfigPut
podman exec "${CONTAINER_NAME}" /usr/sbin/sacli --key "vpn.daemon.0.proto"         --value "udp"  ConfigPut
podman exec "${CONTAINER_NAME}" /usr/sbin/sacli --key "vpn.daemon.1.listen.port"   --value "4344" ConfigPut
podman exec "${CONTAINER_NAME}" /usr/sbin/sacli --key "vpn.daemon.1.proto"         --value "tcp"  ConfigPut
podman exec "${CONTAINER_NAME}" /usr/sbin/sacli start

echo "[+] Estado del contenedor:"
podman ps | grep "${CONTAINER_NAME}" || echo "Contenedor no está en ejecución"

# 3. Configuración de firewalld
echo "[+] Configurando firewall..."
sudo firewall-cmd --permanent --add-port=944/tcp
sudo firewall-cmd --permanent --add-port=4334/tcp
sudo firewall-cmd --permanent --add-port=1195/udp
sudo firewall-cmd --reload

echo "[+] Estado de firewalld:"
sudo firewall-cmd --list-all

# 4. Crear servicio systemd
echo "[+] Creando servicio systemd..."
podman generate systemd --name "${CONTAINER_NAME}" --files > container-${CONTAINER_NAME}.service
sudo mv container-${CONTAINER_NAME}.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable container-${CONTAINER_NAME}.service
sudo systemctl restart container-${CONTAINER_NAME}.service

echo "[✔] Instalación y configuración de OpenVPN-AS completada."
echo "   - Admin UI: https://${HOSTNAME_FQDN}:944"
echo "   - Usuario: ${ADMIN_USER}"
echo "   - Contraseña: ${ADMIN_PASS}"

