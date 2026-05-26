#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Ventoy"

warn "Este processo apaga o pendrive selecionado."
section "Discos detectados"
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS

printf '%bDispositivo do pendrive, ex: /dev/sdb: %b' "$ARCH_BLUE" "$RESET"
read -r device
if [[ ! "$device" =~ ^/dev/[a-zA-Z0-9]+$ ]]; then
  fail "Dispositivo invalido. Use o disco inteiro, exemplo /dev/sdb, nao /dev/sdb1."
  exit 1
fi
if [[ ! -b "$device" ]]; then
  fail "Dispositivo nao encontrado: $device"
  exit 1
fi

printf '%bVersao do Ventoy [1.1.11]: %b' "$ARCH_BLUE" "$RESET"
read -r version
version="${version:-1.1.11}"

printf '%bUsar GPT? [s/N]: %b' "$ARCH_BLUE" "$RESET"
read -r use_gpt
printf '%bHabilitar Secure Boot? [s/N]: %b' "$ARCH_BLUE" "$RESET"
read -r use_secure

flags=(-i)
[[ "$use_gpt" == "s" || "$use_gpt" == "S" ]] && flags+=(-g)
[[ "$use_secure" == "s" || "$use_secure" == "S" ]] && flags+=(-s)

if ! confirm_phrase "VENTOY" "Digite VENTOY para instalar em $device e apagar o conteudo"; then
  exit 0
fi

need_sudo
need_cmd tar
if ! cmd_exists wget && ! cmd_exists curl; then
  fail "Instale wget ou curl para baixar o Ventoy."
  exit 1
fi

workdir="$HOME/Downloads"
archive="$workdir/ventoy-$version-linux.tar.gz"
url="https://github.com/ventoy/Ventoy/releases/download/v$version/ventoy-$version-linux.tar.gz"
mkdir -p "$workdir"

if [[ ! -f "$archive" ]]; then
  if cmd_exists wget; then
    run wget -O "$archive" "$url"
  else
    run curl -L -o "$archive" "$url"
  fi
else
  ok "Arquivo ja existe: $archive"
fi

run tar -xzf "$archive" -C "$workdir"
ventoy_dir="$workdir/ventoy-$version"
if [[ ! -x "$ventoy_dir/Ventoy2Disk.sh" && ! -f "$ventoy_dir/Ventoy2Disk.sh" ]]; then
  fail "Script Ventoy2Disk.sh nao encontrado em $ventoy_dir"
  exit 1
fi

for part in "${device}"?*; do
  [[ -b "$part" ]] && sudo umount "$part" 2>/dev/null || true
done

run sudo sh "$ventoy_dir/Ventoy2Disk.sh" "${flags[@]}" "$device"
