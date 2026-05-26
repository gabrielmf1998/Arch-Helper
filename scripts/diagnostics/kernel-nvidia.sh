#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Diagnostico: Kernel / NVIDIA"

section "Kernel em uso"
uname -sr
uname -a

section "Kernels instalados"
if cmd_exists pacman; then
  pacman -Qq | grep -E '^(linux|linux-lts|linux-zen|linux-hardened|linux-cachyos|linux-cachyos-lts|linux-cachyos-bore|linux-cachyos-deckify|linux-cachyos-eevdf|linux-cachyos-rt|linux-cachyos-server)$' || true
else
  warn "pacman nao encontrado"
fi

section "Pacotes NVIDIA"
if cmd_exists pacman; then
  pacman -Q | grep -Ei '(^|-)nvidia($|-)' || true
else
  warn "pacman nao encontrado"
fi

section "Modulo nvidia"
lsmod | grep -E '^nvidia' || warn "Modulo nvidia nao carregado"

section "nvidia-smi"
if cmd_exists nvidia-smi; then
  nvidia-smi
else
  warn "nvidia-smi nao encontrado"
fi

section "GPU PCI"
if cmd_exists lspci; then
  lspci | grep -Ei 'vga|3d|display' || true
else
  warn "lspci nao encontrado"
fi
