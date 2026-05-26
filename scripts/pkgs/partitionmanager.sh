#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "KDE Partition Manager"

if confirm "Instalar partitionmanager?"; then
  pacman_install partitionmanager
fi
