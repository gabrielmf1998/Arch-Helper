#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="${ARCHHELPER_APP_NAME:-ArchHelper}"
REPO_OWNER="${ARCHHELPER_REPO_OWNER:-gabrielmf1998}"
REPO_NAME="${ARCHHELPER_REPO_NAME:-Arch-Helper}"
BRANCH="${ARCHHELPER_BRANCH:-main}"
ARCHIVE_URL="${ARCHHELPER_ARCHIVE_URL:-https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${BRANCH}.tar.gz}"

info() {
  printf '[ArchHelper] %s\n' "$*"
}

fail() {
  printf '[ArchHelper][erro] %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Comando obrigatorio nao encontrado: $1"
}

download_file() {
  local url="$1"
  local output="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fL --progress-bar "$url" -o "$output"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$output" "$url"
  else
    fail "Instale curl ou wget para baixar o ArchHelper."
  fi
}

if [[ "$(id -u)" == "0" ]]; then
  fail "Nao execute o launcher como root. Rode com seu usuario normal; o TUI pedira sudo quando precisar."
fi

need_cmd tar
need_cmd date

DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
INSTALL_DIR="$DOWNLOAD_DIR/$APP_NAME"
ARCHIVE_PATH="$DOWNLOAD_DIR/${APP_NAME}-${BRANCH}.tar.gz"
EXTRACT_DIR="$DOWNLOAD_DIR/.${APP_NAME}-extract-$$"
EXTRACTED_DIR="$EXTRACT_DIR/${REPO_NAME}-${BRANCH}"

cleanup() {
  rm -rf "$EXTRACT_DIR"
}
trap cleanup EXIT

mkdir -p "$DOWNLOAD_DIR"

info "Repositorio: ${REPO_OWNER}/${REPO_NAME} (${BRANCH})"
info "Baixando pacote .tar.gz para: $ARCHIVE_PATH"
download_file "$ARCHIVE_URL" "$ARCHIVE_PATH"

info "Extraindo em: $DOWNLOAD_DIR"
rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR"
tar -xzf "$ARCHIVE_PATH" -C "$EXTRACT_DIR"

if [[ ! -d "$EXTRACTED_DIR" ]]; then
  found_dir="$(find "$EXTRACT_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  [[ -n "${found_dir:-}" ]] || fail "Nao foi possivel localizar o diretorio extraido."
  EXTRACTED_DIR="$found_dir"
fi

if [[ -e "$INSTALL_DIR" ]]; then
  BACKUP_DIR="${INSTALL_DIR}.bak.$(date +%Y%m%d-%H%M%S)"
  info "Instalacao anterior encontrada. Movendo para: $BACKUP_DIR"
  mv "$INSTALL_DIR" "$BACKUP_DIR"
fi

mv "$EXTRACTED_DIR" "$INSTALL_DIR"
find "$INSTALL_DIR" -type f -name '*.sh' -exec chmod +x {} +

ENTRYPOINT="$INSTALL_DIR/tui-arch-helper.sh"
[[ -f "$ENTRYPOINT" ]] || fail "Entrada principal nao encontrada: $ENTRYPOINT"

info "ArchHelper instalado em: $INSTALL_DIR"
info "Iniciando TUI..."

if [[ -z "${ARCHHELPER_NO_TTY:-}" && -r /dev/tty ]]; then
  exec bash "$ENTRYPOINT" < /dev/tty
fi

exec bash "$ENTRYPOINT"
