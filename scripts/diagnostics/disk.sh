#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Diagnostico: Disco"

section "lsblk"
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS,MODEL,TRAN

section "df -hT"
df -hT

section "Uso de inode"
df -ih

section "fstab"
if [[ -f /etc/fstab ]]; then
  sed -n '1,200p' /etc/fstab
else
  warn "/etc/fstab nao encontrado"
fi
