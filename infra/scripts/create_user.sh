#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] Run as root" >&2
  exit 1
fi

NEW_USER="${1:-deploy}"
PUBKEY_PATH="${2:-}"

if id -u "$NEW_USER" >/dev/null 2>&1; then
  echo "[INFO] User '$NEW_USER' already exists"
else
  adduser --disabled-password --gecos "" "$NEW_USER"
  echo "[OK] User '$NEW_USER' created"
fi

usermod -aG sudo "$NEW_USER"

install -d -m 700 -o "$NEW_USER" -g "$NEW_USER" "/home/$NEW_USER/.ssh"

if [[ -n "$PUBKEY_PATH" && -f "$PUBKEY_PATH" ]]; then
  install -m 600 -o "$NEW_USER" -g "$NEW_USER" "$PUBKEY_PATH" "/home/$NEW_USER/.ssh/authorized_keys"
  echo "[OK] Public key installed"
else
  echo "[WARN] Public key was not provided. Add it manually to /home/$NEW_USER/.ssh/authorized_keys"
fi

echo "[DONE] User bootstrap complete"
