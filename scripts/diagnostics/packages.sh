#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Diagnostico: Pacotes"

need_cmd pacman

count_cmd() {
  { "$@" 2>/dev/null || true; } | awk 'NF {count++} END {print count + 0}'
}

section "Resumo pacman"
printf 'Total pacman: %s\n' "$(count_cmd pacman -Qq)"
printf 'Explicitos: %s\n' "$(count_cmd pacman -Qqe)"
printf 'Dependencias: %s\n' "$(count_cmd pacman -Qqd)"
printf 'Orfaos: %s\n' "$(count_cmd pacman -Qdtq)"
printf 'AUR/foreign: %s\n' "$(count_cmd pacman -Qqm)"

section "Orfaos"
pacman -Qdtq 2>/dev/null || true

section "Pacotes foreign/AUR"
pacman -Qqm 2>/dev/null || true

section "Pacotes explicitos - top 200"
pacman -Qqe 2>/dev/null | sed -n '1,200p'
