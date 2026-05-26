#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "r2modman"

info "Baixe o pacote .pacman no GitHub do r2modmanPlus e informe o caminho aqui."
printf '%bCaminho do r2modman-*.pacman: %b' "$ARCH_BLUE" "$RESET"
read -r pkg_file

if [[ ! -f "$pkg_file" ]]; then
  fail "Arquivo nao encontrado: $pkg_file"
  exit 1
fi

if ! confirm "Instalar dependencia http-parser e depois $pkg_file?"; then
  exit 0
fi

if pacman -Si http-parser >/dev/null 2>&1; then
  pacman_install http-parser
else
  aur_install http-parser
fi
need_sudo
run sudo pacman -U "$pkg_file"
