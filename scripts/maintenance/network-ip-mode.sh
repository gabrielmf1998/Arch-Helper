#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

mask_to_prefix() {
  local mask="$1"
  local IFS=.
  local -a octets
  local octet prefix=0

  if [[ "$mask" =~ ^[0-9]{1,2}$ ]] && ((mask >= 0 && mask <= 32)); then
    printf '%s' "$mask"
    return 0
  fi

  read -r -a octets <<< "$mask"
  if ((${#octets[@]} != 4)); then
    return 1
  fi

  for octet in "${octets[@]}"; do
    case "$octet" in
      255) prefix=$((prefix + 8)) ;;
      254) prefix=$((prefix + 7)) ;;
      252) prefix=$((prefix + 6)) ;;
      248) prefix=$((prefix + 5)) ;;
      240) prefix=$((prefix + 4)) ;;
      224) prefix=$((prefix + 3)) ;;
      192) prefix=$((prefix + 2)) ;;
      128) prefix=$((prefix + 1)) ;;
      0) ;;
      *) return 1 ;;
    esac
  done

  printf '%s' "$prefix"
}

active_connection() {
  nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | awk -F: '$2 != "" {print $1; exit}'
}

title "Rede: fixar IP ou DHCP"

need_cmd nmcli

section "Estado atual"
run nmcli device status || true
printf '\n'
run nmcli connection show --active || true

default_conn="$(active_connection || true)"
printf '\n%bPerfil NetworkManager [%s]: %b' "$ARCH_BLUE" "${default_conn:-sem ativo}" "$RESET"
read -r conn
conn="${conn:-$default_conn}"

if [[ -z "$conn" ]]; then
  fail "Informe um perfil NetworkManager valido."
  exit 1
fi

printf '\n'
menu_item 1 "Fixar IPv4 manual"
menu_item 2 "Voltar IPv4 para DHCP"
menu_back
read_choice mode

case "$mode" in
  1)
    printf '%bIPv4 desejado, ex: 192.168.0.50: %b' "$ARCH_BLUE" "$RESET"
    read -r ip
    printf '%bMascara ou prefixo, ex: 255.255.255.0 ou 24: %b' "$ARCH_BLUE" "$RESET"
    read -r mask
    printf '%bGateway, ex: 192.168.0.1: %b' "$ARCH_BLUE" "$RESET"
    read -r gw
    printf '%bDNS [1.1.1.1 8.8.8.8]: %b' "$ARCH_BLUE" "$RESET"
    read -r dns
    dns="${dns:-1.1.1.1 8.8.8.8}"

    prefix="$(mask_to_prefix "$mask")" || {
      fail "Mascara/prefixo invalido: $mask"
      exit 1
    }

    if ! confirm "Aplicar IPv4 fixo $ip/$prefix gateway $gw no perfil \"$conn\"?"; then
      exit 0
    fi

    run nmcli connection modify "$conn" \
      ipv4.method manual \
      ipv4.addresses "$ip/$prefix" \
      ipv4.gateway "$gw" \
      ipv4.dns "$dns" \
      connection.autoconnect yes
    run nmcli connection down "$conn" || true
    run nmcli connection up "$conn"
    ;;
  2)
    if ! confirm "Voltar o perfil \"$conn\" para receber IPv4 via DHCP?"; then
      exit 0
    fi

    run nmcli connection modify "$conn" \
      ipv4.method auto \
      ipv4.addresses "" \
      ipv4.gateway "" \
      ipv4.dns "" \
      connection.autoconnect yes
    run nmcli connection down "$conn" || true
    run nmcli connection up "$conn"
    ;;
  0|q|Q)
    exit 0
    ;;
  *)
    warn "Opcao invalida"
    exit 1
    ;;
esac

section "Rede apos ajuste"
nmcli device status || true
printf '\n'
nmcli connection show --active || true
