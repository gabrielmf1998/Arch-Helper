#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Fastfetch no bash/Konsole"

line='command -v fastfetch >/dev/null && fastfetch'
target="$HOME/.bashrc"

if grep -qxF "$line" "$target" 2>/dev/null; then
  ok "Linha ja existe em $target"
else
  if confirm "Adicionar fastfetch ao abrir o bash?"; then
    printf '\n%s\n' "$line" >> "$target"
    ok "Linha adicionada em $target"
  fi
fi
