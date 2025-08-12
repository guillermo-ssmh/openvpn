#!/bin/bash
set -e

SERVICE_NAME="noip"
ENV_FILE_DIR="/opt/noip"
ENV_FILE_SRC="$(dirname "$(realpath "$0")")/noip.env"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "[+] Creando carpeta para archivo .env en ${ENV_FILE_DIR}"
sudo mkdir -p "${ENV_FILE_DIR}"

echo "[+] Copiando ${ENV_FILE_SRC} a ${ENV_FILE_DIR}/noip.env"
sudo cp "${ENV_FILE_SRC}" "${ENV_FILE_DIR}/noip.env"
sudo chmod 600 "${ENV_FILE_DIR}/noip.env"

echo "[+] Creando archivo systemd ${SERVICE_FILE}"
sudo tee "${SERVICE_FILE}" > /dev/null <<EOF
[Unit]
Description=No-IP Dynamic Update Client (Podman)
After=network-online.target
Wants=network-online.target

[Service]
Restart=always
ExecStartPre=/usr/bin/podman rm -f ${SERVICE_NAME} 2>/dev/null || true
ExecStart=/usr/bin/podman run --rm --name=${SERVICE_NAME} \\
  --env-file ${ENV_FILE_DIR}/noip.env \\
  ghcr.io/noipcom/noip-duc:latest
ExecStop=/usr/bin/podman stop ${SERVICE_NAME}

[Install]
WantedBy=multi-user.target
EOF

echo "[+] Recargando systemd"
sudo systemctl daemon-reload

echo "[+] Habilitando y arrancando servicio ${SERVICE_NAME}"
sudo systemctl enable --now "${SERVICE_NAME}"

echo "[+] Estado del servicio:"
sudo systemctl status "${SERVICE_NAME}" --no-pager

