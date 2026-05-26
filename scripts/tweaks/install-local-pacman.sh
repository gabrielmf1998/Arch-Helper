#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Instalar pacote local .pacman"

printf '%bCaminho do pacote local: %b' "$ARCH_BLUE" "$RESET"
read -r pkg_file
[[ -f "$pkg_file" ]] || { fail "Arquivo nao encontrado: $pkg_file"; exit 1; }

if confirm "Instalar $pkg_file com pacman -U?"; then
  need_sudo
  run sudo pacman -U "$pkg_file"
fi
