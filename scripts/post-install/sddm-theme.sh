#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "SDDM: tema de login KDE"

info "O ajuste recomendado e trocar o tema pelo menu do proprio KDE."

if cmd_exists kcmshell6; then
  if confirm "Abrir configuracao do SDDM agora?"; then
    run kcmshell6 kcm_sddm
  fi
elif cmd_exists kcmshell5; then
  if confirm "Abrir configuracao do SDDM agora?"; then
    run kcmshell5 kcm_sddm
  fi
else
  warn "kcmshell nao encontrado. Abra em: Configuracoes do Sistema > Cores e Temas > Tela de Login (SDDM)."
fi
