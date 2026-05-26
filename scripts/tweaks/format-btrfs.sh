#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Formatar SSD/HD em Btrfs"

warn "Isto apaga todos os dados da particao escolhida."
section "Discos detectados"
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS,MODEL

printf '%bParticao para formatar, ex: /dev/sda3: %b' "$ARCH_BLUE" "$RESET"
read -r part
[[ -b "$part" ]] || { fail "Particao nao encontrada: $part"; exit 1; }

printf '%bLabel do filesystem [Arquivos]: %b' "$ARCH_BLUE" "$RESET"
read -r label
label="${label:-Arquivos}"

if ! confirm_phrase "FORMATAR" "Digite FORMATAR para apagar $part e criar Btrfs"; then
  exit 0
fi

need_sudo
pacman -Q btrfs-progs >/dev/null 2>&1 || pacman_install btrfs-progs
run sudo umount "$part" || true
run sudo mkfs.btrfs -f -L "$label" "$part"
run sudo mount "$part" /mnt
run sudo chown -R "$USER:$USER" /mnt
run sudo umount "$part"
ok "$part formatado como Btrfs com label $label"
