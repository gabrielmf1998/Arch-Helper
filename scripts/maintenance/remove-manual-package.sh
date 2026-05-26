#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Remover programa instalado fora do gerenciador"

printf '%bNome do programa/executavel: %b' "$ARCH_BLUE" "$RESET"
read -r program
if [[ -z "$program" || "$program" == */* ]]; then
  fail "Informe apenas o nome do executavel, sem barras."
  exit 1
fi

exe="$(command -v "$program" 2>/dev/null || true)"
if [[ -n "$exe" ]]; then
  info "Executavel encontrado: $exe"
  if confirm "Remover $exe com sudo rm?"; then
    need_sudo
    run sudo rm "$exe"
  fi
else
  warn "Executavel nao encontrado no PATH."
fi

config_dir="$HOME/.config/$program"
if [[ -d "$config_dir" ]] && confirm "Remover config $config_dir?"; then
  run rm -rf "$config_dir"
fi

section "Vestigios encontrados"
warn "Revise a lista antes de apagar qualquer coisa manualmente."
run sudo find / -name "*$program*" 2>/dev/null || true
