#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Parsec"

warn "No Linux, Parsec costuma servir apenas como cliente, nao como host."
if confirm "Instalar parsec-bin via AUR helper?"; then
  aur_install parsec-bin
fi
