#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] Run as root" >&2
  exit 1
fi

DOMAIN="${1:-}"
EMAIL="${2:-}"

if [[ -z "$DOMAIN" || -z "$EMAIL" ]]; then
  echo "Usage: sudo $0 <domain> <email>"
  exit 1
fi

apt-get update
apt-get install -y certbot python3-certbot-nginx

certbot --nginx -d "$DOMAIN" -d "www.$DOMAIN" --non-interactive --agree-tos -m "$EMAIL" --redirect

cat >/etc/cron.d/certbot-renew-check <<'CRON'
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
0 3 * * * root certbot renew --quiet --deploy-hook "systemctl reload nginx"
CRON

chmod 644 /etc/cron.d/certbot-renew-check

if systemctl list-unit-files | grep -q '^certbot.timer'; then
  systemctl enable --now certbot.timer
fi

echo "[INFO] Renewal dry-run"
certbot renew --dry-run

echo "[DONE] TLS certificate installed and auto-renew configured"
