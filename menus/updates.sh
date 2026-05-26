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
  menu_header "Updates"
  menu_item 1 "Atualizar pacman + AUR + Flatpak"
  menu_back
  read_choice choice

  case "$choice" in
    1) run_and_pause "$ROOT_DIR/scripts/maintenance/system-update.sh" ;;
    0|q|Q) exit 0 ;;
    *) warn "Opcao invalida"; pause ;;
  esac
done
