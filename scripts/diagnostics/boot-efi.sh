#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Diagnostico: Boot / EFI"

section "Mounts de boot"
for target in /boot /efi /boot/efi; do
  printf '%s\n' "$target"
  findmnt "$target" 2>/dev/null || warn "$target nao montado"
  printf '\n'
done

section "Firmware"
if [[ -d /sys/firmware/efi ]]; then
  ok "Sistema inicializado em UEFI"
else
  warn "Sistema aparenta estar em Legacy/BIOS ou /sys/firmware/efi indisponivel"
fi

section "Bootloader detectado"
[[ -d /boot/grub ]] && printf 'GRUB: /boot/grub encontrado\n'
[[ -d /boot/loader ]] && printf 'systemd-boot/loader entries: /boot/loader encontrado\n'
for efi_dir in /boot/efi/EFI /efi/EFI; do
  if [[ -d "$efi_dir" ]]; then
    printf '%s:\n' "$efi_dir"
    find "$efi_dir" -maxdepth 1 -mindepth 1 -type d -printf '  %f\n' 2>/dev/null | sort || true
  fi
done
if cmd_exists bootctl; then
  bootctl status --no-pager 2>/dev/null || true
fi

section "Ordem UEFI"
if cmd_exists efibootmgr; then
  efibootmgr 2>/dev/null || warn "efibootmgr nao conseguiu ler a NVRAM"
else
  warn "efibootmgr nao instalado"
fi

section "Cmdline do kernel"
cat /proc/cmdline 2>/dev/null || warn "/proc/cmdline indisponivel"
