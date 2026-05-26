#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Fastfetch"

if ! confirm "Instalar fastfetch e aplicar config Arch?"; then
  exit 0
fi

pacman_install fastfetch

mkdir -p "$HOME/.config/fastfetch"
config="$HOME/.config/fastfetch/config.jsonc"
if [[ -f "$config" ]]; then
  backup="$config.bak.$(date +%F-%H%M%S)"
  run cp "$config" "$backup"
fi

cat > "$config" <<'EOF'
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

  "logo": {
    "type": "builtin",
    "source": "arch",
    "padding": {
      "right": 3
    },
    "color": {
      "1": "#1793D1",
      "2": "#333333"
    }
  },

  "display": {
    "separator": "  :: ",
    "color": {
      "keys": "#1793D1",
      "title": "#1793D1",
      "separator": "#333333"
    },
    "key": {
      "type": "both"
    }
  },

  "modules": [
    "title",
    "separator",
    "os",
    "host",
    "kernel",
    "uptime",
    "packages",
    "shell",
    "de",
    "wm",
    "terminal",
    "cpu",
    "gpu",
    "memory",
    "disk",
    "localip",
    "break",
    "colors"
  ]
}
EOF

ok "Config escrita em $config"
run fastfetch || true
