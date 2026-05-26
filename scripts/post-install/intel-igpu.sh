#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "iGPU Intel: Vulkan"

if confirm "Instalar vulkan-intel e lib32-vulkan-intel?"; then
  pacman_install vulkan-intel lib32-vulkan-intel
fi
