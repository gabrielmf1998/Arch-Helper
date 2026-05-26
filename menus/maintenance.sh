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
  menu_header "Maintenance"
  menu_item 1 "PrismLauncher: corrigir audio robotizado"
  menu_item 2 "Remover programa instalado fora do gerenciador"
  menu_item 3 "Recriar cache de icones KDE"
  menu_item 4 "Desbloquear usuario por failed pass"
  menu_item 5 "NTFS dirty: ntfsfix -d"
  menu_item 6 "Restaurar GRUB UEFI limpo"
  menu_item 7 "Vesktop: bloquear alteracao de volume do mic"
  menu_item 8 "Rede: fixar IP ou voltar para DHCP"
  menu_back
  read_choice choice

  case "$choice" in
    1) run_and_pause "$ROOT_DIR/scripts/maintenance/prism-audio.sh" ;;
    2) run_and_pause "$ROOT_DIR/scripts/maintenance/remove-manual-package.sh" ;;
    3) run_and_pause "$ROOT_DIR/scripts/maintenance/kde-icons-refresh.sh" ;;
    4) run_and_pause "$ROOT_DIR/scripts/maintenance/unlock-user-faillock.sh" ;;
    5) run_and_pause "$ROOT_DIR/scripts/maintenance/ntfs-dirty-fix.sh" ;;
    6) run_and_pause "$ROOT_DIR/scripts/maintenance/grub-restore.sh" ;;
    7) run_and_pause "$ROOT_DIR/scripts/maintenance/vesktop-mic-block.sh" ;;
    8) run_and_pause "$ROOT_DIR/scripts/maintenance/network-ip-mode.sh" ;;
    0|q|Q) exit 0 ;;
    *) warn "Opcao invalida"; pause ;;
  esac
done
