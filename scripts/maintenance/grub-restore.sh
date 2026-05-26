#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Restaurar GRUB UEFI limpo"

warn "Este script reinstala o GRUB em UEFI usando /boot/efi e remove /boot/grub antes de recriar."
warn "Nao execute se seu sistema nao usa GRUB UEFI em /boot/efi."

section "Estado atual"
findmnt /boot /boot/efi 2>/dev/null || true
[[ -d /sys/firmware/efi ]] && ok "UEFI detectado" || warn "UEFI nao detectado"

if ! confirm_phrase "REINSTALAR GRUB" "Digite REINSTALAR GRUB para continuar"; then
  exit 0
fi

need_sudo

run sudo mkdir -p /root/grub-backup
run sudo cp -a /etc/default/grub /etc/grub.d /boot/grub /root/grub-backup/ 2>/dev/null || true
run sudo cp -a /boot/efi/EFI /root/grub-backup/EFI-backup 2>/dev/null || true

run sudo sed -i -E 's/^([[:space:]]*GRUB_THEME=)/#\1/' /etc/default/grub
run sudo sed -i -E 's/^([[:space:]]*GRUB_BACKGROUND=)/#\1/' /etc/default/grub

run sudo pacman -S grub efibootmgr

run sudo rm -rf /boot/grub
run sudo mkdir -p /boot/grub

run sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck
run sudo grub-mkconfig -o /boot/grub/grub.cfg

section "Verificacao de tema/background"
sudo grep -Ei "theme|background|minecraft" /etc/default/grub /boot/grub/grub.cfg || true

ok "Backup mantido em /root/grub-backup"
warn "Reinicie quando estiver pronto para validar o GRUB."
