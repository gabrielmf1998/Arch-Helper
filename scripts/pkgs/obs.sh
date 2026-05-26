#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "OBS Studio"

if confirm "Instalar obs-studio?"; then
  pacman_install obs-studio
fi
