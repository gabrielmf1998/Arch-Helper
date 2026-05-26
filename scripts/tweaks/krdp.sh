#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "kRDP"

if confirm "Instalar krdp?"; then
  pacman_install krdp
fi

if cmd_exists firewall-cmd && confirm "Liberar RDP 3389/tcp no firewalld?"; then
  need_sudo
  for zone in $(sudo firewall-cmd --get-zones); do
    run sudo firewall-cmd --permanent --zone="$zone" --add-port=3389/tcp
  done
  run sudo firewall-cmd --reload
elif cmd_exists ufw && confirm "Liberar RDP 3389/tcp no UFW?"; then
  need_sudo
  run sudo ufw allow 3389/tcp
  run sudo ufw reload
fi

if cmd_exists kcmshell6 && confirm "Abrir configuracao do kRDP no KDE?"; then
  run kcmshell6 kcm_krdpserver
else
  info "Abra Configuracoes do Sistema e procure por RDP ou Desktop Remoto."
fi
