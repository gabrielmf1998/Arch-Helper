#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "SoundWire"

if confirm "Instalar soundwire via AUR helper?"; then
  aur_install soundwire
fi

if confirm "Instalar dependencias PipeWire/PulseAudio?"; then
  pacman_install pipewire-pulse pipewire-alsa pavucontrol
fi

if cmd_exists ufw && confirm "Liberar portas SoundWire no UFW?"; then
  need_sudo
  run sudo ufw allow 59011/udp
  run sudo ufw allow 59010/udp
  run sudo ufw reload
elif cmd_exists firewall-cmd && confirm "Liberar portas SoundWire no firewalld?"; then
  need_sudo
  for zone in $(sudo firewall-cmd --get-zones); do
    run sudo firewall-cmd --permanent --zone="$zone" --add-port=59011/udp
    run sudo firewall-cmd --permanent --zone="$zone" --add-port=59010/udp
  done
  run sudo firewall-cmd --reload
fi

section "Servidor de audio"
pactl info 2>/dev/null | grep "Server Name" || warn "pactl indisponivel"
