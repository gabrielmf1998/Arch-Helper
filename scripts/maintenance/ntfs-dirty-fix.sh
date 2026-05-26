#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "NTFS dirty: ntfsfix -d"

section "Discos"
lsblk -f

printf '%bParticao NTFS, ex: /dev/sda3: %b' "$ARCH_BLUE" "$RESET"
read -r part
[[ -b "$part" ]] || { fail "Particao nao encontrada: $part"; exit 1; }

section "Logs recentes"
dmesg | tail -n 20 || true

if ! confirm "Instalar ntfs-3g e executar ntfsfix -d em $part?"; then
  exit 0
fi

pacman_install ntfs-3g
need_sudo
run sudo ntfsfix -d "$part"
ok "ntfsfix finalizado. Tente montar novamente no Dolphin."
