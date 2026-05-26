#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Kernels"

section "Kernel em uso"
uname -sr

section "Pacotes relacionados a linux"
if cmd_exists pacman; then
  pacman -Q | grep linux || true
else
  warn "pacman nao encontrado"
fi
