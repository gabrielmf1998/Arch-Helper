#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Roblox/Sober"

if confirm "Instalar org.vinegarhq.Sober via Flathub?"; then
  flatpak_install org.vinegarhq.Sober
fi
