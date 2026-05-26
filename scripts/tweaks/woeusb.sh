#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "WoeUSB"

if confirm "Instalar woeusb-ng via AUR helper?"; then
  aur_install woeusb-ng
fi

section "Discos detectados"
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS

printf '%bCaminho da ISO Windows: %b' "$ARCH_BLUE" "$RESET"
read -r iso
[[ -f "$iso" ]] || { fail "ISO nao encontrada: $iso"; exit 1; }

printf '%bDispositivo destino, ex: /dev/sdb: %b' "$ARCH_BLUE" "$RESET"
read -r device
[[ -b "$device" ]] || { fail "Dispositivo nao encontrado: $device"; exit 1; }

if ! confirm_phrase "WOEUSB" "Digite WOEUSB para apagar $device e gravar a ISO"; then
  exit 0
fi

need_sudo
run sudo woeusb --device "$iso" "$device" --target-filesystem NTFS
