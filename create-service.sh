#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="hytale"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

HYTALE_DIR="/opt/hytale_server"
JAR_PATH="${HYTALE_DIR}/Server/HytaleServer.jar"
ASSETS_PATH="${HYTALE_DIR}/Assets.zip"
WORKDIR="${HYTALE_DIR}/Server"

RUN_USER="hytale"
RUN_GROUP="hytale"

JAVA_BIN="/usr/bin/java"
JAVA_ARGS=(-jar "${JAR_PATH}" --assets "${ASSETS_PATH}")

# --- Must run as root ---
if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: This script must be run as root."
  echo "Example: su -c './install-hytale-service.sh'   (or run it in a root shell)"
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

# --- Create system user/group if missing ---
if ! getent group "${RUN_GROUP}" >/dev/null 2>&1; then
  groupadd --system "${RUN_GROUP}"
fi

if ! id -u "${RUN_USER}" >/dev/null 2>&1; then
  useradd \
    --system \
    --gid "${RUN_GROUP}" \
    --home-dir "${HYTALE_DIR}" \
    --shell /usr/sbin/nologin \
    "${RUN_USER}"
fi

# --- Permissions (server can write logs/config as needed) ---
mkdir -p "${HYTALE_DIR}"
chown -R "${RUN_USER}:${RUN_GROUP}" "${HYTALE_DIR}"

# --- Write systemd unit ---
cat > "${SERVICE_FILE}" <<EOF
[Unit]
Description=Hytale Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${RUN_USER}
Group=${RUN_GROUP}
WorkingDirectory=${WORKDIR}
ExecStart=${JAVA_BIN} ${JAVA_ARGS[*]}
Restart=on-failure
RestartSec=5
TimeoutStopSec=30

# Hardening (reasonable defaults; remove lines if something breaks)
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=true
ReadWritePaths=${HYTALE_DIR}

[Install]
WantedBy=multi-user.target
EOF

# --- Apply + enable ---
systemctl daemon-reload
systemctl enable "${SERVICE_NAME}.service"

echo "Service installed: ${SERVICE_FILE}"
echo "Next commands:"
echo "  systemctl start ${SERVICE_NAME}"
echo "  systemctl status ${SERVICE_NAME} -l"
echo "  journalctl -u ${SERVICE_NAME} -f"
