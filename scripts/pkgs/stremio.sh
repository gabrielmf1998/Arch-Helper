#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Stremio"

if confirm "Instalar com.stremio.Stremio via Flathub?"; then
  flatpak_install com.stremio.Stremio
fi
