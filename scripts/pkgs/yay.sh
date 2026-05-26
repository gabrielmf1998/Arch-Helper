#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "AUR helper: yay"

if cmd_exists yay; then
  ok "yay ja esta instalado: $(command -v yay)"
  yay --version | head -n 1 || true
  exit 0
fi

if [[ "$(id -u)" == "0" ]]; then
  fail "Nao execute makepkg como root. Rode o TUI com seu usuario normal."
  exit 1
fi

if ! confirm "Instalar dependencias e compilar yay do AUR?"; then
  exit 0
fi

pacman_install base-devel git

build_dir="${YAY_BUILD_DIR:-$HOME/yay}"
if [[ -d "$build_dir/.git" ]]; then
  info "Repositorio yay ja existe em $build_dir. Atualizando."
  run git -C "$build_dir" pull --ff-only
elif [[ -e "$build_dir" ]]; then
  fail "$build_dir ja existe, mas nao parece ser um repositorio Git."
  exit 1
else
  run git clone https://aur.archlinux.org/yay.git "$build_dir"
fi

run makepkg -Crsif --needed --noconfirm -D "$build_dir"
ok "yay instalado."
