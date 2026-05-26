#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Diagnostico: Servicos criticos"

services=(
  NetworkManager.service
  sddm.service
  sshd.service
  firewalld.service
  bluetooth.service
  cups.service
  flatpak-system-helper.service
)

printf '%-32s %-12s %-12s\n' "Servico" "Ativo" "Habilitado"
hr
for service in "${services[@]}"; do
  active="$(systemctl is-active "$service" 2>/dev/null || true)"
  enabled="$(systemctl is-enabled "$service" 2>/dev/null || true)"
  printf '%-32s %-12s %-12s\n' "$service" "${active:-n/a}" "${enabled:-n/a}"
done

section "Falhas systemd"
systemctl --failed --no-pager || true
