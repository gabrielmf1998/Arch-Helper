#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Codecs + PipeWire"

packages=(
  ffmpeg
  gst-plugins-base
  gst-plugins-good
  gst-plugins-bad
  gst-plugins-ugly
  gst-libav
  vlc
  mpv
  pipewire
  pipewire-audio
  pipewire-alsa
  pipewire-pulse
  pipewire-jack
  wireplumber
  gst-plugin-pipewire
  xdg-desktop-portal
  xdg-desktop-portal-kde
  kpipewire
  pavucontrol
  qpwgraph
)

optional_vlc_plugins=(
  vlc-plugin-ffmpeg
  vlc-plugins-base
  vlc-plugins-video-output
)

if ! confirm "Instalar codecs, PipeWire e ferramentas de audio/video?"; then
  exit 0
fi

pacman_install "${packages[@]}"

available_optional=()
for pkg in "${optional_vlc_plugins[@]}"; do
  if pacman -Si "$pkg" >/dev/null 2>&1; then
    available_optional+=("$pkg")
  fi
done
if ((${#available_optional[@]} > 0)); then
  info "Instalando plugins VLC disponiveis no repositorio atual."
  pacman_install "${available_optional[@]}"
fi

section "Config PipeWire 48 kHz"
mkdir -p "$HOME/.config/pipewire/pipewire.conf.d"
config="$HOME/.config/pipewire/pipewire.conf.d/10-sample-rate.conf"
if [[ -f "$config" ]]; then
  backup="$config.bak.$(date +%F-%H%M%S)"
  run cp "$config" "$backup"
fi
cat > "$config" <<'EOF'
context.properties = {
    default.clock.rate = 48000
    default.clock.allowed-rates = [ 48000 ]
}
EOF
ok "Config escrita em $config"
warn "Reinicie o computador depois para aplicar tudo."
