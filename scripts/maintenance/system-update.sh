#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Atualizacao do sistema"

if ! confirm "Executar pacman -Syu, AUR helper e Flatpak update?"; then
  exit 0
fi

need_sudo
run sudo pacman -Syu

if cmd_exists yay; then
  run yay -Syu --aur
elif cmd_exists paru; then
  run paru -Syu --aur
else
  warn "Nenhum AUR helper encontrado. Pulando AUR."
fi

if cmd_exists flatpak; then
  run flatpak update -y
  run flatpak uninstall --unused -y
else
  warn "Flatpak nao instalado. Pulando Flatpak."
fi

ok "Atualizacao finalizada."
