#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Firewall: Minecraft 25565"

if ! confirm "Liberar porta 25565 TCP/UDP em todas as zonas do firewalld?"; then
  exit 0
fi

need_cmd firewall-cmd
need_sudo

for zone in $(sudo firewall-cmd --get-zones); do
  run sudo firewall-cmd --permanent --zone="$zone" --add-port=25565/tcp
  run sudo firewall-cmd --permanent --zone="$zone" --add-port=25565/udp
done
run sudo firewall-cmd --reload
ok "Porta 25565 liberada."
