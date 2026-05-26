#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Hytale flatpak local"

need_cmd flatpak
printf '%bCaminho do arquivo .flatpak: %b' "$ARCH_BLUE" "$RESET"
read -r flatpak_file

if [[ ! -f "$flatpak_file" ]]; then
  fail "Arquivo nao encontrado: $flatpak_file"
  exit 1
fi

if confirm "Instalar $flatpak_file?"; then
  run flatpak install "$flatpak_file"
fi
