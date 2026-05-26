#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Desbloquear usuario por failed pass"

printf '%bUsuario [%s]: %b' "$ARCH_BLUE" "$USER" "$RESET"
read -r target_user
target_user="${target_user:-$USER}"

if confirm "Resetar faillock do usuario $target_user?"; then
  need_sudo
  run sudo faillock --user "$target_user" --reset
fi
