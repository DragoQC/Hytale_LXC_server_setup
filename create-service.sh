#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="hytale"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

HYTALE_DIR="/opt/hytale_server"
JAR_PATH="${HYTALE_DIR}/Server/HytaleServer.jar"
ASSETS_PATH="${HYTALE_DIR}/Assets.zip"
WORKDIR="${HYTALE_DIR}/Server"

JAVA_BIN="/usr/bin/java"
JAVA_ARGS=(-jar "${JAR_PATH}" --assets "${ASSETS_PATH}")

# --- Must run as root ---
if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: This script must be run as root."
  echo "Example: su -c './create-service.sh' (or run it in a root shell)"
  exit 1
fi

# --- Basic validation ---
if [[ ! -f "${JAR_PATH}" ]]; then
  echo "ERROR: Not found: ${JAR_PATH}"
  echo "Make sure the server is installed in ${HYTALE_DIR} before creating the service."
  exit 1
fi

if [[ ! -f "${ASSETS_PATH}" ]]; then
  echo "ERROR: Not found: ${ASSETS_PATH}"
  exit 1
fi

if [[ ! -x "${JAVA_BIN}" ]]; then
  echo "ERROR: Java not found at ${JAVA_BIN}"
  echo "Install Temurin/OpenJDK 25 and ensure /usr/bin/java exists."
  exit 1
fi

# Ensure base dir exists (keep ownership as-is; root is fine)
mkdir -p "${HYTALE_DIR}"

# --- Write systemd unit (runs as root by default) ---
cat > "${SERVICE_FILE}" <<EOF
[Unit]
Description=Hytale Server (root)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=${WORKDIR}
ExecStart=${JAVA_BIN} ${JAVA_ARGS[*]}
Restart=on-failure
RestartSec=5
TimeoutStopSec=30

# Minimal hardening that usually won't break auth/token storage
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}.service"

echo "Service installed: ${SERVICE_FILE}"
echo "Next commands:"
echo "  systemctl start ${SERVICE_NAME}"
echo "  systemctl status ${SERVICE_NAME} -l"
echo "  journalctl -u ${SERVICE_NAME} -f"