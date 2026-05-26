#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Vesktop: bloquear volume do microfone"

config_dir="$HOME/.config/pipewire/pipewire-pulse.conf.d"
config="$config_dir/10-vesktop-block-source-volume.conf"

if [[ -f "$config" ]]; then
  backup="$config.bak.$(date +%F-%H%M%S)"
  run cp "$config" "$backup"
fi

if confirm "Criar regra PipeWire para impedir Vesktop de mexer no volume do mic?"; then
  mkdir -p "$config_dir"
  cat > "$config" <<'EOF'
pulse.rules = [
  {
    matches = [
      { application.process.binary = "vesktop" }
    ]
    actions = {
      quirks = [ block-source-volume ]
    }
  }
]
EOF
  ok "Regra escrita em $config"
  warn "Reinicie a sessao ou o PipeWire para aplicar."
fi
