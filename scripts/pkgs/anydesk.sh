#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "AnyDesk"

if confirm "Instalar com.anydesk.Anydesk via Flathub?"; then
  flatpak_install com.anydesk.Anydesk
fi
