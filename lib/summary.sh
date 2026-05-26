#!/usr/bin/env bash

# Compact dashboard shown at the top of the TUI.

_trim_spaces() {
  sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//'
}

_quick() {
  timeout "${SUMMARY_TIMEOUT:-2}" bash -c "$*" 2>/dev/null | _trim_spaces || true
}

_first_line() {
  sed -n '1p' | _trim_spaces
}

_count_lines() {
  awk 'NF {count++} END {print count + 0}'
}

_truncate() {
  local text="$1"
  local max="${2:-110}"
  if ((${#text} > max)); then
    printf '%s...' "${text:0:max-3}"
  else
    printf '%s' "$text"
  fi
}

_yesno_cmd() {
  if cmd_exists "$1"; then
    printf 'sim'
  else
    printf 'nao'
  fi
}

_mount_summary() {
  local target="$1"
  local line
  line="$(_quick "findmnt -nro SOURCE,FSTYPE,TARGET '$target' | head -n 1")"
  [[ -n "$line" ]] && printf '%s' "$line" || printf 'nao montado'
}

summary_system() {
  local host kernel uptime session de plasma
  host="$(_quick "hostnamectl --static 2>/dev/null || cat /proc/sys/kernel/hostname 2>/dev/null")"
  [[ -n "$host" ]] || host="n/a"
  kernel="$(uname -r 2>/dev/null || printf 'n/a')"
  uptime="$(_quick "uptime -p")"
  session="${XDG_SESSION_TYPE:-n/a}"
  de="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-n/a}}"
  plasma="$(_quick "plasmashell --version | head -n 1")"
  [[ -n "$plasma" ]] || plasma="Plasma n/a"
  printf '%s | kernel %s | %s | %s/%s | %s' "$host" "$kernel" "${uptime:-uptime n/a}" "$session" "$de" "$plasma"
}

summary_boot() {
  local boot efi loader order cmdline
  boot="$(_mount_summary /boot)"
  if findmnt -rn /boot/efi >/dev/null 2>&1; then
    efi="$(_mount_summary /boot/efi)"
  elif findmnt -rn /efi >/dev/null 2>&1; then
    efi="$(_mount_summary /efi)"
  else
    efi="EFI nao montado"
  fi
  if [[ -d /boot/grub ]]; then
    loader="GRUB"
  elif bootctl status >/dev/null 2>&1; then
    loader="systemd-boot"
  elif [[ -d /boot/loader ]]; then
    loader="loader entries"
  else
    loader="n/a"
  fi
  order="$(_quick "efibootmgr 2>/dev/null | awk -F': ' '/BootCurrent|BootOrder/ {print \$1 \"=\" \$2}' | paste -sd ' ' -")"
  cmdline="$(cat /proc/cmdline 2>/dev/null | _first_line)"
  printf '/boot: %s | EFI: %s | %s | %s | cmdline: %s' "$boot" "$efi" "$loader" "${order:-UEFI n/a}" "$(_truncate "$cmdline" 80)"
}

summary_disk() {
  local root inode fstab
  root="$(_quick "df -hT / | awk 'NR==2 {print \$2 \":\" \$4 \"/\" \$3 \" usado \" \$6}'")"
  inode="$(_quick "df -ih / | awk 'NR==2 {print \"inode \" \$5}'")"
  fstab="$(_quick "awk 'NF && \$1 !~ /^#/ {count++} END {print count + 0}' /etc/fstab")"
  printf '%s | %s | fstab %s entradas' "${root:-df n/a}" "${inode:-inode n/a}" "${fstab:-0}"
}

summary_packages() {
  if ! cmd_exists pacman; then
    printf 'pacman n/a'
    return 0
  fi
  local total explicit deps orphans foreign
  total="$({ pacman -Qq 2>/dev/null || true; } | _count_lines)"
  explicit="$({ pacman -Qqe 2>/dev/null || true; } | _count_lines)"
  deps="$({ pacman -Qqd 2>/dev/null || true; } | _count_lines)"
  orphans="$({ pacman -Qdtq 2>/dev/null || true; } | _count_lines)"
  foreign="$({ pacman -Qqm 2>/dev/null || true; } | _count_lines)"
  printf 'total %s | explicitos %s | deps %s | orfaos %s | foreign/AUR %s' "$total" "$explicit" "$deps" "$orphans" "$foreign"
}

summary_flatpak_aur() {
  local fp remotes apps yay paru
  fp="$(_yesno_cmd flatpak)"
  remotes=0
  apps=0
  if cmd_exists flatpak; then
    remotes="$({ flatpak remotes --columns=name 2>/dev/null || true; } | _count_lines)"
    apps="$({ flatpak list --app --columns=application 2>/dev/null || true; } | _count_lines)"
  fi
  yay="$(_yesno_cmd yay)"
  paru="$(_yesno_cmd paru)"
  printf 'flatpak %s | remotes %s | apps %s | yay %s | paru %s' "$fp" "$remotes" "$apps" "$yay" "$paru"
}

summary_kernel_nvidia() {
  local running kernels nvpkg module smi gpu
  running="$(uname -r 2>/dev/null || printf 'n/a')"
  kernels=0
  nvpkg=0
  if cmd_exists pacman; then
    kernels="$({ pacman -Qq 2>/dev/null | grep -E '^(linux|linux-lts|linux-zen|linux-hardened|linux-cachyos|linux-cachyos-lts|linux-cachyos-bore|linux-cachyos-deckify|linux-cachyos-eevdf|linux-cachyos-rt|linux-cachyos-server)$' || true; } | _count_lines)"
    nvpkg="$({ pacman -Qq 2>/dev/null | grep -Ei '(^|-)nvidia($|-)' || true; } | _count_lines)"
  fi
  if lsmod 2>/dev/null | awk '{print $1}' | grep -qx nvidia; then
    module="modulo sim"
  else
    module="modulo nao"
  fi
  smi="$(_quick "nvidia-smi --query-gpu=name,driver_version --format=csv,noheader | head -n 1")"
  [[ -n "$smi" ]] || smi="nvidia-smi n/a"
  gpu="$(_quick "lspci | grep -Ei 'vga|3d|display' | cut -d' ' -f2- | head -n 2 | paste -sd '; ' -")"
  printf '%s | kernels %s | nvidia pkgs %s | %s | %s | GPU: %s' "$running" "$kernels" "$nvpkg" "$module" "$smi" "$(_truncate "${gpu:-n/a}" 70)"
}

summary_services() {
  printf 'NM:%s sddm:%s sshd:%s firewalld:%s bluetooth:%s cups:%s flatpak:%s' \
    "$(service_state NetworkManager.service)" \
    "$(service_state sddm.service)" \
    "$(service_state sshd.service)" \
    "$(service_state firewalld.service)" \
    "$(service_state bluetooth.service)" \
    "$(service_state cups.service)" \
    "$(service_state flatpak-system-helper.service)"
}

summary_network() {
  local ipaddr route dns nm
  ipaddr="$(_quick "ip -4 -o addr show scope global | awk '{split(\$4,a,\"/\"); print a[1]; exit}'")"
  route="$(_quick "ip route show default | awk 'NR==1 {print \"via \" \$3 \" dev \" \$5}'")"
  dns="$(_quick "resolvectl dns 2>/dev/null | awk -F': ' 'NF > 1 && \$2 != \"\" {print \$2; exit}'")"
  [[ -n "$dns" ]] || dns="$(_quick "awk '/^nameserver/ {print \$2; exit}' /etc/resolv.conf")"
  nm="$(_quick "nmcli -t -f STATE general 2>/dev/null | head -n 1")"
  printf 'IP %s | rota %s | DNS %s | NM %s' "${ipaddr:-n/a}" "${route:-n/a}" "${dns:-n/a}" "${nm:-n/a}"
}

summary_boot_perf() {
  local time
  time="$(_quick "systemd-analyze time --no-pager 2>/dev/null")"
  printf '%s' "${time:-systemd-analyze n/a}"
}

summary_line() {
  local label="$1"
  local text="$2"
  local width max
  width="$(term_width)"
  max=$((width - 19))
  ((max < 40)) && max=40
  printf '%b%-16s%b %s\n' "$ARCH_BLUE" "$label" "$RESET" "$(_truncate "$text" "$max")"
}

_short_uptime() {
  local up
  up="$(_quick "uptime -p")"
  up="${up#up }"
  printf '%s' "${up:-n/a}"
}

_plasma_short() {
  local version
  version="$(_quick "plasmashell --version | awk '{print \$2}'")"
  printf '%s' "${version:-n/a}"
}

_bootloader_short() {
  if [[ -d /boot/grub ]]; then
    printf 'GRUB'
  elif bootctl status >/dev/null 2>&1; then
    printf 'systemd-boot'
  elif [[ -d /boot/loader ]]; then
    printf 'loader'
  else
    printf 'n/a'
  fi
}

_efi_short() {
  if findmnt -rn /boot/efi >/dev/null 2>&1; then
    printf '/boot/efi'
  elif findmnt -rn /efi >/dev/null 2>&1; then
    printf '/efi'
  else
    printf 'nao montado'
  fi
}

_root_usage_short() {
  _quick "df -h / | awk 'NR==2 {print \$5 \" de \" \$2}'"
}

_boot_time_short() {
  local time
  time="$(_quick "systemd-analyze time --no-pager 2>/dev/null | awk -F'= ' '{print \$2}'")"
  [[ -n "$time" ]] || time="$(_quick "systemd-analyze time --no-pager 2>/dev/null | sed -E 's/^Startup finished in //'")"
  printf '%s' "${time:-n/a}"
}

_service_short() {
  local service="$1"
  if systemctl is-active --quiet "$service" 2>/dev/null; then
    printf 'ok'
  else
    printf 'off'
  fi
}

_service_enabled_active_short() {
  local service="$1"
  local enabled active
  enabled="$(systemctl is-enabled "$service" 2>/dev/null || true)"
  active="$(systemctl is-active "$service" 2>/dev/null || true)"

  case "$enabled" in
    enabled) enabled="hab" ;;
    disabled) enabled="des" ;;
    masked) enabled="mask" ;;
    static) enabled="static" ;;
    *) enabled="n/a" ;;
  esac

  case "$active" in
    active) active="on" ;;
    failed) active="fail" ;;
    *) active="off" ;;
  esac

  printf '%s/%s' "$enabled" "$active"
}

_ipv6_local_short() {
  local ipv6
  ipv6="$(_quick "ip -6 -o addr show scope link | awk '{split(\$4,a,\"/\"); print a[1] \" \" \$2; exit}'")"
  printf '%s' "${ipv6:-n/a}"
}

_disks_short() {
  local disks
  disks="$(_quick "lsblk -dn -o NAME,SIZE,TYPE,TRAN | awk '\$3 == \"disk\" && \$1 !~ /^(zram|loop|sr)/ {tran=\$4; if (tran == \"\") tran=\"disk\"; printf \"%s:%s:%s \", \$1, \$2, tran}'")"
  printf '%s' "${disks:-n/a}"
}

_gpu_short() {
  local gpu
  gpu="$(_quick "nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n 1")"
  if [[ -n "$gpu" ]]; then
    printf '%s' "$gpu"
    return 0
  fi
  gpu="$(_quick "lspci | grep -Ei 'vga|3d|display' | sed -E 's/^.*: //' | head -n 1")"
  printf '%s' "${gpu:-n/a}"
}

summary_compact_lines() {
  local host kernel session plasma uptime ip route disk bootloader efi boot_time
  local total orphans foreign flatpak yay paru gpu ipv6 disks
  host="$(_quick "hostnamectl --static 2>/dev/null || cat /proc/sys/kernel/hostname 2>/dev/null")"
  kernel="$(uname -r 2>/dev/null || printf 'n/a')"
  session="${XDG_SESSION_TYPE:-n/a}"
  plasma="$(_plasma_short)"
  uptime="$(_short_uptime)"
  ip="$(_quick "ip -4 -o addr show scope global | awk '{split(\$4,a,\"/\"); print a[1]; exit}'")"
  route="$(_quick "ip route show default | awk 'NR==1 {print \$5}'")"
  disk="$(_root_usage_short)"
  ipv6="$(_ipv6_local_short)"
  disks="$(_disks_short)"
  bootloader="$(_bootloader_short)"
  efi="$(_efi_short)"
  boot_time="$(_boot_time_short)"

  total=0
  orphans=0
  foreign=0
  if cmd_exists pacman; then
    total="$({ pacman -Qq 2>/dev/null || true; } | _count_lines)"
    orphans="$({ pacman -Qdtq 2>/dev/null || true; } | _count_lines)"
    foreign="$({ pacman -Qqm 2>/dev/null || true; } | _count_lines)"
  fi
  flatpak="$(_yesno_cmd flatpak)"
  yay="$(_yesno_cmd yay)"
  paru="$(_yesno_cmd paru)"
  gpu="$(_gpu_short)"

  panel_line "Host: ${host:-n/a}    Kernel: $kernel    Uptime: $uptime"
  panel_line "Sessao: ${session}/Plasma $plasma    IP: ${ip:-n/a} (${route:-sem rota})"
  panel_line "IPv6 local: $(_truncate "$ipv6" 70)"
  panel_line "Disco /: ${disk:-n/a}    Pacotes: $total    AUR/foreign: $foreign    Orfaos: $orphans"
  panel_line "Discos detectados: $(_truncate "$disks" 68)"
  panel_line "Boot: $bootloader    EFI: $efi    Tempo: $boot_time"
  panel_line "Servicos: NM:$(_service_short NetworkManager.service) SDDM:$(_service_short sddm.service) FW:$(_service_short firewalld.service) SSH:$(_service_enabled_active_short sshd.service)"
  panel_line "Apps base: Flatpak:$flatpak Yay:$yay Paru:$paru"
  panel_line "GPU: $(_truncate "$gpu" 70)"
}

print_compact_summary() {
  panel_top "RESUMO DESTE SISTEMA"
  summary_compact_lines
  panel_bottom
}

print_summary() {
  print_compact_summary
}
