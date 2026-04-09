#!/usr/bin/env bash

set -euo pipefail

CONFIG_SRC="${HOME}/.dotfile/.config/nvim"
LAZY_SRC="${HOME}/.local/share/nvim/lazy"
OUT_DIR="${1:-${CONFIG_SRC}/dist/windows-pack}"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_dir() {
  if [ ! -d "$1" ]; then
    echo "Missing required directory: $1" >&2
    exit 1
  fi
}

require_cmd zip
require_dir "$CONFIG_SRC"
require_dir "$LAZY_SRC"

mkdir -p "$OUT_DIR"

CONFIG_ZIP="${OUT_DIR}/nvim-config-${TIMESTAMP}.zip"
LAZY_ZIP="${OUT_DIR}/nvim-lazy-plugins-${TIMESTAMP}.zip"
README_TXT="${OUT_DIR}/README-windows-${TIMESTAMP}.txt"

(
  cd "$(dirname "$CONFIG_SRC")"
  zip -qr "$CONFIG_ZIP" "$(basename "$CONFIG_SRC")"
)

(
  cd "$(dirname "$LAZY_SRC")"
  zip -qr "$LAZY_ZIP" "$(basename "$LAZY_SRC")"
)

cat > "$README_TXT" <<EOF
Neovim Windows transfer package
Created: ${TIMESTAMP}

Files in this folder
- $(basename "$CONFIG_ZIP")
- $(basename "$LAZY_ZIP")

Copy targets on Windows
1. Extract $(basename "$CONFIG_ZIP") to:
   %LOCALAPPDATA%\\nvim

2. Extract $(basename "$LAZY_ZIP") to:
   %LOCALAPPDATA%\\nvim-data\\lazy

Notes
- This package includes your Neovim config and lazy.nvim plugin checkout cache.
- Do not copy macOS-built Mason tools directly to Windows.
- Do not copy macOS Treesitter parsers directly to Windows.
- Plugins with native binaries may still need to rebuild on Windows.
- If GitHub is blocked, this package can help you start with existing Lua/Vimscript plugins offline.
- If a plugin fails on Windows, open Neovim and reinstall or rebuild that specific plugin later when network access is available.
EOF

printf 'Created:\n- %s\n- %s\n- %s\n' "$CONFIG_ZIP" "$LAZY_ZIP" "$README_TXT"
