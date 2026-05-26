#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Diagnostico: Rede"

section "IP"
ip -brief address 2>/dev/null || hostname -I 2>/dev/null || true

section "Rota default"
ip route show default 2>/dev/null || true

section "DNS"
if cmd_exists resolvectl; then
  resolvectl dns 2>/dev/null || true
  resolvectl status 2>/dev/null | sed -n '1,120p' || true
else
  sed -n '1,120p' /etc/resolv.conf 2>/dev/null || true
fi

section "NetworkManager"
if cmd_exists nmcli; then
  nmcli general status
  printf '\nDispositivos:\n'
  nmcli device status
  printf '\nConexoes:\n'
  nmcli connection show --active
else
  warn "nmcli nao encontrado"
fi
