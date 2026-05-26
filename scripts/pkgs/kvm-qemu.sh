#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "KVM/QEMU + virt-manager"

if ! confirm "Instalar qemu, virt-manager, libvirt e configurar servicos?"; then
  exit 0
fi

pacman_install qemu-desktop virt-manager libvirt dnsmasq swtpm edk2-ovmf
need_sudo

section "libvirt network backend"
if [[ -f /etc/libvirt/network.conf ]] && sudo grep -qxF 'firewall_backend = "iptables"' /etc/libvirt/network.conf; then
  ok "firewall_backend ja configurado"
else
  printf '%s\n' 'firewall_backend = "iptables"' | sudo tee -a /etc/libvirt/network.conf >/dev/null
  ok "firewall_backend adicionado em /etc/libvirt/network.conf"
fi

run sudo usermod -aG libvirt "$USER"
run sudo systemctl enable --now libvirtd.service
run sudo systemctl enable --now libvirtd.socket
run sudo virsh net-autostart default || true
run sudo virsh net-start default || true

if cmd_exists ufw; then
  run sudo ufw route allow from 192.168.122.0/24 || true
  if confirm "Aplicar tambem regras UFW in/out em virbr0 para DHCP de VM?"; then
    run sudo ufw allow in on virbr0
    run sudo ufw allow out on virbr0
    run sudo ufw reload
  fi
fi

section "VirtIO Windows"
info "Drivers VirtIO: https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/"
info "Windows 11 storage: LoadDriver > Virtio > virtstor > w11 > amd64"
info "Windows 11 network: LoadDriver > Virtio > NetKVM > w11 > amd64"
info "Snippets XML de CPU/Hyper-V: $ROOT_DIR/docs/kvm-windows-xml-snippets.md"
warn "Faca logout/login para o grupo libvirt entrar em vigor."
