#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] Run as root" >&2
  exit 1
fi

apt-get update
apt-get upgrade -y
apt-get autoremove -y
apt-get autoclean -y

echo "[DONE] System packages updated"
