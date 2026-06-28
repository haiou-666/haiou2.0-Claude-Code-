#!/bin/bash
# Seagull Install (macOS)
# Wrapper for install.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
INSTALL_SCRIPT="$PARENT_DIR/seagull-files/install.sh"

if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo "[!] install.sh not found"
    exit 1
fi

chmod +x "$INSTALL_SCRIPT"
bash "$INSTALL_SCRIPT"
