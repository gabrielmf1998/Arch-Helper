#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Fontes Konsole"

if confirm "Instalar JetBrains Mono Nerd e Noto Emoji?"; then
  pacman_install ttf-jetbrains-mono-nerd noto-fonts-emoji
  run fc-cache -fv
fi
