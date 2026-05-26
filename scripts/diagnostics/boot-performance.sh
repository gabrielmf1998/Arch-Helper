#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/lib/ui.sh"

title "Diagnostico: Boot performance"

need_cmd systemd-analyze

section "Tempo"
systemd-analyze time --no-pager || true

section "Blame top 30"
systemd-analyze blame --no-pager | sed -n '1,30p' || true

section "Critical chain"
systemd-analyze critical-chain --no-pager || true
