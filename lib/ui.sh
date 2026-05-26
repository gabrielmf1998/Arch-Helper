#!/usr/bin/env bash

# Shared UI and command helpers for TUI Arch Helper.

if [[ -z "${ROOT_DIR:-}" ]]; then
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  RESET=$'\033[0m'
  BOLD=$'\033[1m'
  DIM=$'\033[2m'
  ARCH_BLUE=$'\033[38;2;23;147;209m'
  ARCH_BLUE_DARK=$'\033[38;2;18;102;153m'
  FG=$'\033[38;2;238;242;246m'
  MUTED=$'\033[38;2;152;166;179m'
  GREEN=$'\033[38;2;52;211;153m'
  YELLOW=$'\033[38;2;250;204;21m'
  RED=$'\033[38;2;248;113;113m'
else
  RESET=""
  BOLD=""
  DIM=""
  ARCH_BLUE=""
  ARCH_BLUE_DARK=""
  FG=""
  MUTED=""
  GREEN=""
  YELLOW=""
  RED=""
fi

clear_screen() {
  printf '\033[2J\033[H'
}

term_width() {
  local cols
  cols="$(tput cols 2>/dev/null || true)"
  [[ "$cols" =~ ^[0-9]+$ ]] || cols=100
  printf '%s' "$cols"
}

tui_width() {
  local cols width
  cols="$(term_width)"
  width="$cols"
  ((width > 92)) && width=92
  ((width < 64)) && width=64
  printf '%s' "$width"
}

repeat_char() {
  local char="${1:-=}"
  local count="${2:-80}"
  local out=""
  local i
  for ((i = 0; i < count; i++)); do
    out+="$char"
  done
  printf '%s' "$out"
}

center_text() {
  local text="$1"
  local width="${2:-$(tui_width)}"
  local pad=0
  ((width > ${#text})) && pad=$(((width - ${#text}) / 2))
  printf '%*s%s' "$pad" "" "$text"
}

hr() {
  local width
  width="$(term_width)"
  printf '%b%s%b\n' "$ARCH_BLUE_DARK" "$(repeat_char "-" "$width")" "$RESET"
}

title() {
  local text="${1:-TUI Arch Helper}"
  local width inner
  width="$(tui_width)"
  inner=$((width - 2))
  printf '%b+%s+%b\n' "$ARCH_BLUE" "$(repeat_char "-" "$inner")" "$RESET"
  printf '%b|%b %b%-*s%b %b|%b\n' "$ARCH_BLUE" "$RESET" "$BOLD$ARCH_BLUE" "$((inner - 2))" "$text" "$RESET" "$ARCH_BLUE" "$RESET"
  printf '%b+%s+%b\n' "$ARCH_BLUE" "$(repeat_char "-" "$inner")" "$RESET"
}

section() {
  printf '\n%b%s%b\n' "$BOLD$ARCH_BLUE" "$1" "$RESET"
  hr
}

info() {
  printf '%b[info]%b %s\n' "$ARCH_BLUE" "$RESET" "$*"
}

ok() {
  printf '%b[ok]%b %s\n' "$GREEN" "$RESET" "$*"
}

warn() {
  printf '%b[aviso]%b %s\n' "$YELLOW" "$RESET" "$*"
}

fail() {
  printf '%b[erro]%b %s\n' "$RED" "$RESET" "$*" >&2
}

pause() {
  printf '\n%bPressione Enter para continuar...%b' "$MUTED" "$RESET"
  read -r _
}

confirm() {
  local prompt="${1:-Continuar?}"
  local answer
  printf '%b%s [s/N]: %b' "$YELLOW" "$prompt" "$RESET"
  if ! read -rsn1 answer; then
    answer=""
  fi
  printf '%s\n' "$answer"
  [[ "$answer" == "s" || "$answer" == "S" || "$answer" == "sim" || "$answer" == "SIM" ]]
}

confirm_phrase() {
  local phrase="$1"
  local prompt="${2:-Digite \"$phrase\" para continuar}"
  local answer
  printf '%b%s: %b' "$YELLOW" "$prompt" "$RESET"
  read -r answer
  [[ "$answer" == "$phrase" ]]
}

cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}

need_cmd() {
  if ! cmd_exists "$1"; then
    fail "Comando obrigatorio nao encontrado: $1"
    return 1
  fi
}

need_sudo() {
  need_cmd sudo || return 1
  sudo -v
}

command_description() {
  local first="${1:-}"
  local second="${2:-}"
  local third="${3:-}"

  if [[ "$first" == "sudo" ]]; then
    first="${2:-}"
    second="${3:-}"
    third="${4:-}"
  fi

  case "$first:$second:$third" in
    pacman:-S:*) printf 'Instalar/atualizar pacotes pelo pacman' ;;
    pacman:-Syu:*) printf 'Atualizar o sistema pelo pacman' ;;
    pacman:-U:*) printf 'Instalar pacote local pelo pacman' ;;
    flatpak:install:*) printf 'Instalar aplicativo Flatpak' ;;
    flatpak:update:*) printf 'Atualizar aplicativos Flatpak' ;;
    flatpak:uninstall:*) printf 'Remover runtimes Flatpak nao usados' ;;
    firewall-cmd:*:*) printf 'Alterar regra do firewalld' ;;
    ufw:*:*) printf 'Alterar regra do UFW' ;;
    systemctl:enable:*) printf 'Habilitar/iniciar servico systemd' ;;
    systemctl:restart:*) printf 'Reiniciar servico systemd' ;;
    systemctl:reload:*) printf 'Recarregar servico systemd' ;;
    nmcli:device:status) printf 'Mostrar dispositivos de rede no NetworkManager' ;;
    nmcli:connection:show) printf 'Mostrar conexoes do NetworkManager' ;;
    nmcli:connection:modify) printf 'Alterar perfil de rede no NetworkManager' ;;
    nmcli:connection:down) printf 'Derrubar perfil de rede no NetworkManager' ;;
    nmcli:connection:up) printf 'Subir perfil de rede no NetworkManager' ;;
    zerotier-cli:join:*) printf 'Entrar em rede ZeroTier' ;;
    git:clone:*) printf 'Clonar repositorio Git' ;;
    git:-C:*) printf 'Atualizar repositorio Git existente' ;;
    makepkg:*:*) printf 'Compilar/instalar pacote AUR' ;;
    npm:i:*) printf 'Instalar pacote global pelo npm' ;;
    npm:config:*) printf 'Configurar npm do usuario' ;;
    wget:*:*) printf 'Baixar arquivo pela internet' ;;
    curl:*:*) printf 'Baixar arquivo pela internet' ;;
    tar:*:*) printf 'Extrair arquivo compactado' ;;
    cp:*:*) printf 'Copiar arquivo/diretorio' ;;
    rm:*:*) printf 'Remover arquivo/diretorio' ;;
    mkdir:*:*) printf 'Criar diretorio' ;;
    mount:*:*) printf 'Montar filesystem' ;;
    umount:*:*) printf 'Desmontar filesystem' ;;
    mkfs.btrfs:*:*) printf 'Formatar filesystem Btrfs' ;;
    chown:*:*) printf 'Alterar dono/permissoes de arquivo' ;;
    sed:*:*) printf 'Editar arquivo via sed' ;;
    grub-install:*:*) printf 'Instalar GRUB na EFI' ;;
    grub-mkconfig:*:*) printf 'Gerar configuracao do GRUB' ;;
    virsh:*:*) printf 'Alterar configuracao libvirt' ;;
    testparm:*:*) printf 'Validar configuracao Samba' ;;
    smbpasswd:*:*) printf 'Configurar senha Samba' ;;
    ntfsfix:*:*) printf 'Corrigir flags/estado de particao NTFS' ;;
    faillock:*:*) printf 'Resetar bloqueio de login do usuario' ;;
    woeusb:*:*) printf 'Gravar ISO Windows no dispositivo selecionado' ;;
    sh:*:*) printf 'Executar script shell' ;;
    du:*:*) printf 'Calcular tamanho de diretorios' ;;
    find:*:*) printf 'Buscar arquivos no sistema' ;;
    echo:*:*) printf 'Exibir texto no terminal' ;;
    *) printf 'Executar comando' ;;
  esac
}

format_command() {
  printf '%q ' "$@"
}

run() {
  local description command_text
  description="$(command_description "$@")"
  command_text="$(format_command "$@")"
  printf '%bAcao:%b %s\n' "$ARCH_BLUE" "$RESET" "$description"
  printf '%bComando:%b %s\n' "$ARCH_BLUE" "$RESET" "$command_text"
  if ! confirm "Executar este comando?"; then
    warn "Comando cancelado pelo usuario."
    return 130
  fi
  printf '%b$%b ' "$ARCH_BLUE" "$RESET"
  printf '%s' "$command_text"
  printf '\n'
  "$@"
}

run_shell() {
  local command="$1"
  printf '%bAcao:%b Executar comando shell\n' "$ARCH_BLUE" "$RESET"
  printf '%bComando:%b %s\n' "$ARCH_BLUE" "$RESET" "$command"
  if ! confirm "Executar este comando?"; then
    warn "Comando cancelado pelo usuario."
    return 130
  fi
  printf '%b$%b %s\n' "$ARCH_BLUE" "$RESET" "$command"
  bash -euo pipefail -c "$command"
}

pacman_install() {
  need_sudo || return 1
  run sudo pacman -S --needed "$@"
}

aur_helper() {
  if cmd_exists yay; then
    printf 'yay'
    return 0
  fi
  if cmd_exists paru; then
    printf 'paru'
    return 0
  fi
  return 1
}

aur_install() {
  local helper
  if ! helper="$(aur_helper)"; then
    fail "Nenhum AUR helper encontrado. Instale yay ou paru primeiro."
    return 1
  fi
  run "$helper" -S --needed "$@"
}

flatpak_install() {
  if ! cmd_exists flatpak; then
    fail "Flatpak nao esta instalado. Execute o setup de Flatpak primeiro."
    return 1
  fi
  run flatpak install -y flathub "$@"
}

service_state() {
  local service="$1"
  if ! cmd_exists systemctl; then
    printf 'n/a'
    return 0
  fi
  if systemctl is-active --quiet "$service" 2>/dev/null; then
    printf 'ativo'
  elif systemctl is-enabled --quiet "$service" 2>/dev/null; then
    printf 'inativo'
  else
    printf 'off'
  fi
}

run_task() {
  local script="$1"
  shift || true
  if [[ ! -f "$script" ]]; then
    fail "Script nao encontrado: $script"
    return 1
  fi
  bash "$script" "$@"
}

menu_header() {
  clear_screen
  title "$1"
}

menu_item() {
  printf '  %b[%s]%b %s\n' "$ARCH_BLUE" "$1" "$RESET" "$2"
}

menu_back() {
  printf '  %b[%s]%b %s\n' "$MUTED" "0" "$RESET" "Voltar"
}

read_choice() {
  local var_name="${1:-choice}"
  local value
  printf '\n%bEscolha:%b ' "$ARCH_BLUE" "$RESET"
  if ! read -rsn1 value; then
    value="q"
  fi
  printf '%s\n' "$value"
  printf -v "$var_name" '%s' "$value"
}

app_header() {
  local width inner logo_line logo_canvas logo_width subtitle
  width="$(tui_width)"
  inner=$((width - 2))
  logo_width=18
  subtitle="Arch Linux post-install, diagnostics and maintenance"

  printf '%b+%s+%b\n' "$ARCH_BLUE" "$(repeat_char "=" "$inner")" "$RESET"
  for logo_line in \
    "        /\\" \
    "       /  \\" \
    "      / /\ \\" \
    "     / ____ \\" \
    "    /_/    \\_\\"; do
    logo_canvas="$(printf "%-${logo_width}s" "$logo_line")"
    printf '%b|%b%b%-*s%b%b|%b\n' "$ARCH_BLUE" "$RESET" "$ARCH_BLUE" "$inner" "$(center_text "$logo_canvas" "$inner")" "$RESET" "$ARCH_BLUE" "$RESET"
  done
  printf '%b|%b%b%-*s%b%b|%b\n' "$ARCH_BLUE" "$RESET" "$BOLD$FG" "$inner" "$(center_text "TUI ARCH HELPER" "$inner")" "$RESET" "$ARCH_BLUE" "$RESET"
  printf '%b|%b%b%-*s%b%b|%b\n' "$ARCH_BLUE" "$RESET" "$MUTED" "$inner" "$(center_text "$subtitle" "$inner")" "$RESET" "$ARCH_BLUE" "$RESET"
  printf '%b+%s+%b\n' "$ARCH_BLUE" "$(repeat_char "=" "$inner")" "$RESET"
}

panel_top() {
  local label="${1:-}"
  local width inner line
  width="$(tui_width)"
  inner=$((width - 2))
  line="$(repeat_char "-" "$inner")"
  if [[ -n "$label" && ${#label} -lt $((inner - 4)) ]]; then
    local prefix suffix
    prefix=" $label "
    suffix_len=$((inner - ${#prefix}))
    printf '%b+%b%s%b%s%b+%b\n' "$ARCH_BLUE" "$BOLD$ARCH_BLUE" "$prefix" "$ARCH_BLUE_DARK" "$(repeat_char "-" "$suffix_len")" "$ARCH_BLUE" "$RESET"
  else
    printf '%b+%s+%b\n' "$ARCH_BLUE" "$line" "$RESET"
  fi
}

panel_line() {
  local text="$1"
  local width inner max
  width="$(tui_width)"
  inner=$((width - 2))
  max=$((inner - 2))
  ((${#text} > max)) && text="${text:0:max-3}..."
  printf '%b|%b %-*s %b|%b\n' "$ARCH_BLUE" "$RESET" "$max" "$text" "$ARCH_BLUE" "$RESET"
}

panel_blank() {
  panel_line ""
}

panel_bottom() {
  local width inner
  width="$(tui_width)"
  inner=$((width - 2))
  printf '%b+%s+%b\n' "$ARCH_BLUE" "$(repeat_char "-" "$inner")" "$RESET"
}

main_menu_grid() {
  local width inner col row
  width="$(tui_width)"
  inner=$((width - 2))
  col=$(((inner - 5) / 2))

  panel_top "MENU"
  row="$(printf '%-*s  %s' "$col" "[1] Diagnosticos" "[2] Post Installation")"
  panel_line "$row"
  row="$(printf '%-*s  %s' "$col" "[3] Pkgs" "[4] Tweaks")"
  panel_line "$row"
  row="$(printf '%-*s  %s' "$col" "[5] Maintenance" "[6] Updates")"
  panel_line "$row"
  panel_blank
  panel_line "[0] Sair"
  panel_bottom
}
