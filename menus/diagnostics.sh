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
  menu_header "Diagnosticos detalhados"
  menu_item 1 "Sistema: hostname, kernel, uptime, sessao grafica, KDE/Plasma"
  menu_item 2 "Boot / EFI: mounts, bootloader, ordem UEFI, cmdline"
  menu_item 3 "Disco: lsblk, df, inode, fstab"
  menu_item 4 "Pacotes: pacman, explicitos, dependencias, orfaos, foreign"
  menu_item 5 "Flatpak / AUR: remotes, apps, yay, paru"
  menu_item 6 "Kernel / NVIDIA: kernels, modulo, nvidia-smi, GPU PCI"
  menu_item 7 "Servicos criticos"
  menu_item 8 "Rede"
  menu_item 9 "Boot performance"
  menu_back
  read_choice choice

  case "$choice" in
    1) run_and_pause "$ROOT_DIR/scripts/diagnostics/system.sh" ;;
    2) run_and_pause "$ROOT_DIR/scripts/diagnostics/boot-efi.sh" ;;
    3) run_and_pause "$ROOT_DIR/scripts/diagnostics/disk.sh" ;;
    4) run_and_pause "$ROOT_DIR/scripts/diagnostics/packages.sh" ;;
    5) run_and_pause "$ROOT_DIR/scripts/diagnostics/flatpak-aur.sh" ;;
    6) run_and_pause "$ROOT_DIR/scripts/diagnostics/kernel-nvidia.sh" ;;
    7) run_and_pause "$ROOT_DIR/scripts/diagnostics/services.sh" ;;
    8) run_and_pause "$ROOT_DIR/scripts/diagnostics/network.sh" ;;
    9) run_and_pause "$ROOT_DIR/scripts/diagnostics/boot-performance.sh" ;;
    0|q|Q) exit 0 ;;
    *) warn "Opcao invalida"; pause ;;
  esac
done
