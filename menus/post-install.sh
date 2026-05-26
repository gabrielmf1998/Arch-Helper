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
  menu_header "Post Installation"
  menu_item 1 "SDDM: abrir configuracao de tema KDE"
  menu_item 2 "Codecs + PipeWire + sample rate 48 kHz"
  menu_item 3 "Pendencias iGPU Intel: Vulkan 64/32 bit"
  menu_item 4 "Fastfetch: instalar e aplicar config Arch"
  menu_item 5 "Fontes Konsole: JetBrains Mono Nerd + Emoji"
  menu_item 6 "Fastfetch ao abrir Konsole/bash"
  menu_item 7 "Dolphin/Ark: compressao 7zip"
  menu_item 8 "Firewall: liberar Minecraft 25565 TCP/UDP"
  menu_item 9 "ZeroTier: instalar, entrar na rede e firewall"
  menu_back
  read_choice choice

  case "$choice" in
    1) run_and_pause "$ROOT_DIR/scripts/post-install/sddm-theme.sh" ;;
    2) run_and_pause "$ROOT_DIR/scripts/post-install/codecs-pipewire.sh" ;;
    3) run_and_pause "$ROOT_DIR/scripts/post-install/intel-igpu.sh" ;;
    4) run_and_pause "$ROOT_DIR/scripts/post-install/fastfetch-config.sh" ;;
    5) run_and_pause "$ROOT_DIR/scripts/post-install/konsole-fonts.sh" ;;
    6) run_and_pause "$ROOT_DIR/scripts/post-install/fastfetch-bashrc.sh" ;;
    7) run_and_pause "$ROOT_DIR/scripts/post-install/dolphin-7zip.sh" ;;
    8) run_and_pause "$ROOT_DIR/scripts/post-install/minecraft-firewall.sh" ;;
    9) run_and_pause "$ROOT_DIR/scripts/post-install/zerotier.sh" ;;
    0|q|Q) exit 0 ;;
    *) warn "Opcao invalida"; pause ;;
  esac
done
