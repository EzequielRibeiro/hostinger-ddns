#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
    echo "Execute como root: sudo ./install.sh" >&2
    exit 1
fi

for cmd in install systemctl; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Comando obrigatório ausente: $cmd" >&2
        exit 1
    }
done

if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl jq ca-certificates dnsutils
elif ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1 || ! command -v dig >/dev/null 2>&1; then
    echo "Instale curl, jq e dig/dnsutils antes de continuar." >&2
    exit 1
fi

install -d -m 0755 /etc/hostinger-ddns
install -d -m 0750 /var/lib/hostinger-ddns
install -m 0755 "${SCRIPT_DIR}/hostinger-ddns" /usr/local/sbin/hostinger-ddns

if [[ ! -e /etc/hostinger-ddns/hostinger-ddns.conf ]]; then
    install -m 0644 "${SCRIPT_DIR}/hostinger-ddns.conf" /etc/hostinger-ddns/hostinger-ddns.conf
else
    echo "Mantendo configuração existente: /etc/hostinger-ddns/hostinger-ddns.conf"
fi

if [[ ! -e /etc/hostinger-ddns/token ]]; then
    install -m 0600 "${SCRIPT_DIR}/token.example" /etc/hostinger-ddns/token
    echo
    echo "IMPORTANTE:"
    echo "Edite /etc/hostinger-ddns/token e substitua o texto de exemplo pelo token real da API Hostinger."
    echo
else
    chmod 0600 /etc/hostinger-ddns/token
    echo "Mantendo token existente: /etc/hostinger-ddns/token"
fi

install -m 0644 "${SCRIPT_DIR}/systemd/hostinger-ddns.service" /etc/systemd/system/hostinger-ddns.service
install -m 0644 "${SCRIPT_DIR}/systemd/hostinger-ddns.timer" /etc/systemd/system/hostinger-ddns.timer

systemctl daemon-reload
systemctl enable hostinger-ddns.timer

echo
echo "Instalação concluída."
echo
echo "Estado local:"
echo "   /var/lib/hostinger-ddns/state"
echo
echo "1. Configure o token:"
echo "   sudo nano /etc/hostinger-ddns/token"
echo
echo "2. Teste SEM alterar DNS:"
echo "   sudo hostinger-ddns test"
echo
echo "3. Verifique DNS completo:"
echo "   sudo hostinger-ddns verify"
echo
echo "4. Atualize manualmente:"
echo "   sudo hostinger-ddns update"
echo "   sudo hostinger-ddns update --force"
echo
echo "5. Verifique e corrija automaticamente:"
echo "   sudo hostinger-ddns verify --update"
echo
echo "6. Inicie o timer:"
echo "   sudo systemctl start hostinger-ddns.timer"
echo
echo "7. Confira:"
echo "   sudo hostinger-ddns status"
