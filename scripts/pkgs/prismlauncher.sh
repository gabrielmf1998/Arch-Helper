#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "PrismLauncher"

if confirm "Instalar prismlauncher?"; then
  pacman_install prismlauncher
fi
