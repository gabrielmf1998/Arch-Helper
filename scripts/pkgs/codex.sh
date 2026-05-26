#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Codex CLI"

if ! confirm "Instalar dependencias Node/npm e @openai/codex global no prefixo do usuario?"; then
  exit 0
fi

pacman_install nodejs npm git base-devel python

mkdir -p "$HOME/.local/share/npm"
run npm config set prefix "$HOME/.local/share/npm"

path_line='export PATH="$HOME/.local/share/npm/bin:$PATH"'
if ! grep -qxF "$path_line" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n%s\n' "$path_line" >> "$HOME/.bashrc"
  ok "PATH do npm adicionado em $HOME/.bashrc"
fi

export PATH="$HOME/.local/share/npm/bin:$PATH"
run npm i -g @openai/codex
ok "Codex instalado. Execute: codex"
