#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] Run as root" >&2
  exit 1
fi

SSH_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%Y%m%d%H%M%S)"
cp "$SSH_CONFIG" "$BACKUP"
echo "[OK] Backup created: $BACKUP"

apply_or_append() {
  local key="$1"
  local value="$2"
  if grep -qE "^\s*#?\s*${key}\s+" "$SSH_CONFIG"; then
    sed -ri "s|^\s*#?\s*${key}\s+.*|${key} ${value}|" "$SSH_CONFIG"
  else
    echo "${key} ${value}" >> "$SSH_CONFIG"
  fi
}

apply_or_append "PermitRootLogin" "no"
apply_or_append "PasswordAuthentication" "no"
apply_or_append "PubkeyAuthentication" "yes"
apply_or_append "ChallengeResponseAuthentication" "no"
apply_or_append "X11Forwarding" "no"
apply_or_append "MaxAuthTries" "3"
apply_or_append "ClientAliveInterval" "300"
apply_or_append "ClientAliveCountMax" "2"

sshd -t
systemctl restart ssh || systemctl restart sshd

echo "[DONE] SSH hardening applied"
