#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Recriar cache de icones KDE"

if ! confirm "Limpar caches de icones/thumbnails e reiniciar plasmashell?"; then
  exit 0
fi

run rm -f "$HOME/.cache/icon-cache.kcache"
run rm -f "$HOME"/.cache/ksycoca6*
run rm -f "$HOME"/.cache/ksycoca5*
run rm -rf "$HOME"/.cache/thumbnails/*

if cmd_exists kbuildsycoca6; then
  run kbuildsycoca6 --noincremental
elif cmd_exists kbuildsycoca5; then
  run kbuildsycoca5 --noincremental
else
  warn "kbuildsycoca nao encontrado"
fi

if cmd_exists kquitapp6; then
  kquitapp6 plasmashell 2>/dev/null || true
else
  killall plasmashell 2>/dev/null || true
fi
nohup plasmashell --replace >/dev/null 2>&1 &
ok "Caches recriados e plasmashell reiniciado."
