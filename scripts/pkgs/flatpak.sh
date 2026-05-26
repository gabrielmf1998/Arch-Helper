#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Flatpak"

if ! confirm "Instalar flatpak, flatpak-kcm e adicionar Flathub?"; then
  exit 0
fi

pacman_install flatpak flatpak-kcm
need_sudo
run sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
ok "Flatpak configurado."
