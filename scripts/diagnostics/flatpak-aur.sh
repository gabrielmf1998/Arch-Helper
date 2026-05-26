#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Diagnostico: Flatpak / AUR"

section "Flatpak"
if cmd_exists flatpak; then
  ok "flatpak instalado"
  printf '\nRemotes:\n'
  flatpak remotes 2>/dev/null || true
  printf '\nApps:\n'
  flatpak list --app 2>/dev/null || true
else
  warn "flatpak nao instalado"
fi

section "AUR helpers"
if cmd_exists yay; then
  ok "yay instalado: $(command -v yay)"
  yay --version | head -n 1 || true
else
  warn "yay nao instalado"
fi

if cmd_exists paru; then
  ok "paru instalado: $(command -v paru)"
  paru --version | head -n 1 || true
else
  warn "paru nao instalado"
fi
