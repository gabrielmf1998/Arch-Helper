#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Vesktop"

if confirm "Instalar vesktop via AUR helper?"; then
  aur_install vesktop
fi
