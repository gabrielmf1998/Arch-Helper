#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "PrismLauncher: audio robotizado"

config="$HOME/.alsoftrc"
if [[ -f "$config" ]]; then
  backup="$config.bak.$(date +%F-%H%M%S)"
  run cp "$config" "$backup"
fi

if confirm "Forcar OpenAL/PrismLauncher a usar PulseAudio sobre PipeWire?"; then
  cat > "$config" <<'EOF'
drivers=pulse
EOF
  ok "Config escrita em $config"
  info "Para testar uma execucao isolada: ALSOFT_DRIVERS=pulse prismlauncher"
fi
