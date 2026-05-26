#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

run_and_pause() {
  local script="$1"
  clear_screen
  if ! run_task "$script"; then
    fail "Script finalizou com erro: $script"
  fi
  pause
}

while true; do
  menu_header "Tweaks"
  menu_item 1 "Tmpfs: usar RAM como disco temporario"
  menu_item 2 "Ventoy: criar pendrive bootavel"
  menu_item 3 "WoeUSB: gravar ISO Windows"
  menu_item 4 "Ver tamanho das pastas em /"
  menu_item 5 "Instalar pacote .pacman local"
  menu_item 6 "Formatar SSD/HD em Btrfs"
  menu_item 7 "SoundWire"
  menu_item 8 "Editar config do Cava"
  menu_item 9 "kRDP: KDE via RDP"
  menu_item a "Ver kernels instalados e em uso"
  menu_item b "Samba vmshare"
  menu_back
  read_choice choice

  case "$choice" in
    1) run_and_pause "$ROOT_DIR/scripts/tweaks/tmpfs-ramdisk.sh" ;;
    2) run_and_pause "$ROOT_DIR/scripts/tweaks/ventoy.sh" ;;
    3) run_and_pause "$ROOT_DIR/scripts/tweaks/woeusb.sh" ;;
    4) run_and_pause "$ROOT_DIR/scripts/tweaks/folder-sizes.sh" ;;
    5) run_and_pause "$ROOT_DIR/scripts/tweaks/install-local-pacman.sh" ;;
    6) run_and_pause "$ROOT_DIR/scripts/tweaks/format-btrfs.sh" ;;
    7) run_and_pause "$ROOT_DIR/scripts/tweaks/soundwire.sh" ;;
    8) run_and_pause "$ROOT_DIR/scripts/tweaks/cava-config.sh" ;;
    9) run_and_pause "$ROOT_DIR/scripts/tweaks/krdp.sh" ;;
    a|A) run_and_pause "$ROOT_DIR/scripts/tweaks/kernels.sh" ;;
    b|B) run_and_pause "$ROOT_DIR/scripts/tweaks/samba-vmshare.sh" ;;
    0|q|Q) exit 0 ;;
    *) warn "Opcao invalida"; pause ;;
  esac
done
