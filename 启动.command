#!/bin/bash
# Seagull Launch (macOS)
# Double-click to deploy

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/seagull-files/install.sh"

if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo "[!] install.sh not found at: $INSTALL_SCRIPT"
    echo "    Make sure the folder structure is correct:"
    echo "    - seagull-files/install.sh"
    echo "    - seagull-files/claude-config-bundle/"
    read -p "Press Enter to exit..."
    exit 1
fi

chmod +x "$INSTALL_SCRIPT"
bash "$INSTALL_SCRIPT"
