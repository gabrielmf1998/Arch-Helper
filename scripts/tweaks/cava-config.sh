#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Editar config do Cava"

mkdir -p "$HOME/.config/cava"
config="$HOME/.config/cava/config"
editor="${EDITOR:-}"
if [[ -z "$editor" ]]; then
  if cmd_exists nano; then
    editor="nano"
  elif cmd_exists vim; then
    editor="vim"
  else
    fail "Nenhum editor encontrado. Defina EDITOR ou instale nano/vim."
    exit 1
  fi
fi

run "$editor" "$config"
