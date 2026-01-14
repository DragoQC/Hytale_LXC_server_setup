# Hytale Server – Debian 13 LXC Setup

This repository provides scripts to install and run a **Hytale dedicated server** inside a **Debian 13 LXC container**.

The setup:
- installs Temurin OpenJDK 25
- downloads and initializes the Hytale server
- lets you authenticate using Hytale’s device OAuth flow
- optionally creates a systemd service for automatic startup

---

## 🚀 Installation

> **Requirements**
> - Debian 13 LXC container
> - Root shell (default in LXC)
> - Internet access

Run the installer:

```bash
apt update && apt upgrade -y && apt install -y curl
bash -c "$(curl -fsSL https://raw.githubusercontent.com/DragoQC/Hytale_LXC_server_setup/main/install-server.sh)"
```

## 🔐 Authentication (required)

> **After the server starts for the first time, authenticate it:**
> - Open the URL shown in the terminal
> - Enter the provided authorization code
> - Wait for the CLI to continue automatically

- Once the server console is available, run:
```bash
/auth login device
/auth persistence Encrypted
```
> This links the server to your Hytale account and enables encrypted credential storage.

## ⚙️ Create the systemd service (optional but recommended)
### CURRNELTY NOT WORKING ASK LOGIN EVERYTIME
> - To run the server automatically at boot, create the systemd service:
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/DragoQC/Hytale_LXC_server_setup/main/create-service.sh)"
```
