#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "ZeroTier"

if ! confirm "Instalar e habilitar zerotier-one?"; then
  exit 0
fi

pacman_install zerotier-one
need_sudo
run sudo systemctl enable --now zerotier-one

printf '%bCodigo da rede ZeroTier (vazio para pular join): %b' "$ARCH_BLUE" "$RESET"
read -r network_id
if [[ -n "$network_id" ]]; then
  run sudo zerotier-cli join "$network_id"
fi

if cmd_exists firewall-cmd && confirm "Configurar firewalld para ZeroTier?"; then
  ZT_IFACES="$(ip -o link show | awk -F': ' '$2 ~ /^zt/ {print $2}')"
  for iface in $ZT_IFACES; do
    run sudo firewall-cmd --zone=trusted --change-interface="$iface"
    sudo firewall-cmd --permanent --zone=trusted --add-interface="$iface" 2>/dev/null || \
      run sudo firewall-cmd --permanent --zone=trusted --change-interface="$iface"
  done
  for zone in $(sudo firewall-cmd --get-zones); do
    run sudo firewall-cmd --permanent --zone="$zone" --add-port=9993/udp
  done
  run sudo firewall-cmd --reload
elif cmd_exists ufw && confirm "Configurar UFW para ZeroTier UDP 9993?"; then
  run sudo ufw allow 9993/udp
  run sudo ufw reload
fi

ok "ZeroTier finalizado. Autorize o device no painel do ZeroTier se necessario."
