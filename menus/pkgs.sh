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
  menu_header "Pkgs"
  menu_item 1 "AUR helper: yay"
  menu_item 2 "Octopi"
  menu_item 3 "Flatpak + flathub + flatpak-kcm"
  menu_item 4 "Vesktop"
  menu_item 5 "Telegram"
  menu_item 6 "Google Chrome"
  menu_item 7 "Stremio"
  menu_item 8 "OBS Studio"
  menu_item 9 "AnyDesk"
  menu_item a "PrismLauncher"
  menu_item b "Codex CLI"
  menu_item c "Roblox/Sober"
  menu_item d "VLC"
  menu_item e "Filelight KDE"
  menu_item f "Hytale flatpak local"
  menu_item g "Parsec cliente"
  menu_item h "r2modman local"
  menu_item i "Gwenview"
  menu_item j "KDE Partition Manager"
  menu_item k "KVM/QEMU + virt-manager"
  menu_back
  read_choice choice

  case "$choice" in
    1) run_and_pause "$ROOT_DIR/scripts/pkgs/yay.sh" ;;
    2) run_and_pause "$ROOT_DIR/scripts/pkgs/octopi.sh" ;;
    3) run_and_pause "$ROOT_DIR/scripts/pkgs/flatpak.sh" ;;
    4) run_and_pause "$ROOT_DIR/scripts/pkgs/vesktop.sh" ;;
    5) run_and_pause "$ROOT_DIR/scripts/pkgs/telegram.sh" ;;
    6) run_and_pause "$ROOT_DIR/scripts/pkgs/google-chrome.sh" ;;
    7) run_and_pause "$ROOT_DIR/scripts/pkgs/stremio.sh" ;;
    8) run_and_pause "$ROOT_DIR/scripts/pkgs/obs.sh" ;;
    9) run_and_pause "$ROOT_DIR/scripts/pkgs/anydesk.sh" ;;
    a|A) run_and_pause "$ROOT_DIR/scripts/pkgs/prismlauncher.sh" ;;
    b|B) run_and_pause "$ROOT_DIR/scripts/pkgs/codex.sh" ;;
    c|C) run_and_pause "$ROOT_DIR/scripts/pkgs/roblox-sober.sh" ;;
    d|D) run_and_pause "$ROOT_DIR/scripts/pkgs/vlc.sh" ;;
    e|E) run_and_pause "$ROOT_DIR/scripts/pkgs/filelight.sh" ;;
    f|F) run_and_pause "$ROOT_DIR/scripts/pkgs/hytale-local-flatpak.sh" ;;
    g|G) run_and_pause "$ROOT_DIR/scripts/pkgs/parsec.sh" ;;
    h|H) run_and_pause "$ROOT_DIR/scripts/pkgs/r2modman.sh" ;;
    i|I) run_and_pause "$ROOT_DIR/scripts/pkgs/gwenview.sh" ;;
    j|J) run_and_pause "$ROOT_DIR/scripts/pkgs/partitionmanager.sh" ;;
    k|K) run_and_pause "$ROOT_DIR/scripts/pkgs/kvm-qemu.sh" ;;
    0|q|Q) exit 0 ;;
    *) warn "Opcao invalida"; pause ;;
  esac
done
