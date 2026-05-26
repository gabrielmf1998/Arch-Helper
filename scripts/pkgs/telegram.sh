#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Telegram Desktop"

if confirm "Instalar telegram-desktop?"; then
  pacman_install telegram-desktop
fi
