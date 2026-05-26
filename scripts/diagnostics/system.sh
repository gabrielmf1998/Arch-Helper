#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Diagnostico: Sistema"

section "Host"
hostnamectl 2>/dev/null || cat /proc/sys/kernel/hostname 2>/dev/null || true

section "Kernel"
uname -a

section "Uptime"
uptime -p 2>/dev/null || uptime

section "Sessao grafica"
printf 'XDG_SESSION_TYPE=%s\n' "${XDG_SESSION_TYPE:-n/a}"
printf 'XDG_CURRENT_DESKTOP=%s\n' "${XDG_CURRENT_DESKTOP:-n/a}"
printf 'DESKTOP_SESSION=%s\n' "${DESKTOP_SESSION:-n/a}"
if cmd_exists loginctl; then
  session_id="${XDG_SESSION_ID:-$(loginctl | awk -v user="$USER" '$3 == user {print $1; exit}')}"
  [[ -n "${session_id:-}" ]] && loginctl show-session "$session_id" -p Type -p Desktop -p Display -p Remote 2>/dev/null || true
fi

section "KDE / Plasma"
if cmd_exists plasmashell; then
  plasmashell --version
else
  warn "plasmashell nao encontrado"
fi
if cmd_exists kf6-config; then
  kf6-config --version
elif cmd_exists kf5-config; then
  kf5-config --version
fi
if cmd_exists kinfo; then
  kinfo 2>/dev/null || true
fi
