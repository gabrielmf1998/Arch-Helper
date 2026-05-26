#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Samba vmshare"

printf '%bUsuario Samba [%s]: %b' "$ARCH_BLUE" "$USER" "$RESET"
read -r samba_user
samba_user="${samba_user:-$USER}"

printf '%bDiretorio do share [/srv/vmshare]: %b' "$ARCH_BLUE" "$RESET"
read -r share_dir
share_dir="${share_dir:-/srv/vmshare}"

if ! confirm "Instalar/configurar Samba para $share_dir com usuario $samba_user?"; then
  exit 0
fi

pacman_install samba
need_sudo
run sudo mkdir -p "$share_dir"
run sudo chown -R "$samba_user:$samba_user" "$share_dir"

conf="/etc/samba/smb.conf"
if [[ ! -f "$conf" ]]; then
  sudo mkdir -p /etc/samba
  sudo tee "$conf" >/dev/null <<EOF
[global]
   server role = standalone server
   log file = /var/log/samba/%m
   log level = 2
   map to guest = Never
EOF
fi

if sudo grep -q '^\[vmshare\]' "$conf"; then
  warn "[vmshare] ja existe em $conf. Nao vou duplicar o bloco."
else
  sudo tee -a "$conf" >/dev/null <<EOF

[vmshare]
   path = $share_dir
   browseable = yes
   read only = no
   valid users = $samba_user
   force user = $samba_user
   create mask = 0664
   directory mask = 0775
EOF
  ok "Bloco [vmshare] adicionado em $conf"
fi

run sudo testparm -s
run sudo smbpasswd -a "$samba_user"
run sudo systemctl restart smb
run sudo systemctl enable smb

section "Windows"
info "No CMD do Windows:"
printf 'net use * /delete /y\n'
printf 'net use Z: \\\\192.168.122.1\\vmshare /user:%s\n' "$samba_user"
