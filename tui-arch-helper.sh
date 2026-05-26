#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/ui.sh"
source "$ROOT_DIR/lib/summary.sh"

main_menu() {
  local choice
  while true; do
    clear_screen
    app_header
    printf '\n'
    print_summary
    printf '\n'
    main_menu_grid
    read_choice choice

    case "$choice" in
      1) run_task "$ROOT_DIR/menus/diagnostics.sh" ;;
      2) run_task "$ROOT_DIR/menus/post-install.sh" ;;
      3) run_task "$ROOT_DIR/menus/pkgs.sh" ;;
      4) run_task "$ROOT_DIR/menus/tweaks.sh" ;;
      5) run_task "$ROOT_DIR/menus/maintenance.sh" ;;
      6) run_task "$ROOT_DIR/menus/updates.sh" ;;
      0|q|Q) clear_screen; exit 0 ;;
      *) warn "Opcao invalida"; pause ;;
    esac
  done
}

main_menu
