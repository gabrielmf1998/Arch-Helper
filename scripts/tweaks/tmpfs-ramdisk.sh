#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Tmpfs: RAM como disco"

warn "Tudo que for salvo no tmpfs sera apagado ao desligar/desmontar."
printf '%bPonto de montagem [/mnt/ramdisk]: %b' "$ARCH_BLUE" "$RESET"
read -r mount_point
mount_point="${mount_point:-/mnt/ramdisk}"

printf '%bTamanho [16G]: %b' "$ARCH_BLUE" "$RESET"
read -r size
size="${size:-16G}"

if ! confirm "Montar tmpfs em $mount_point com size=$size?"; then
  exit 0
fi

need_sudo
run sudo mkdir -p "$mount_point"
run sudo mount -t tmpfs -o "size=$size" tmpfs "$mount_point"
ok "Tmpfs montado em $mount_point"
