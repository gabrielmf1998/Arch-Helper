#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Dolphin/Ark: 7zip"

if confirm "Instalar p7zip, ark e kde-cli-tools?"; then
  pacman_install p7zip ark kde-cli-tools
fi
