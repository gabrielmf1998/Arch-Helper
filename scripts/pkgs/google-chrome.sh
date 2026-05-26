#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Google Chrome"

if confirm "Instalar google-chrome via AUR helper?"; then
  aur_install google-chrome
fi
