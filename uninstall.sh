#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Execute como root: sudo ./uninstall.sh" >&2
    exit 1
fi

systemctl disable --now hostinger-ddns.timer 2>/dev/null || true
systemctl stop hostinger-ddns.service 2>/dev/null || true

rm -f /etc/systemd/system/hostinger-ddns.timer
rm -f /etc/systemd/system/hostinger-ddns.service
rm -f /usr/local/sbin/hostinger-ddns
rm -rf /var/lib/hostinger-ddns

systemctl daemon-reload

echo "Binário, units systemd e estado local removidos."
echo
echo "Por segurança, /etc/hostinger-ddns NÃO foi removido automaticamente."
echo "Ele contém seu token da API."
echo
echo "Para removê-lo também:"
echo "  sudo rm -rf /etc/hostinger-ddns"
