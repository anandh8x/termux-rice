#!/usr/bin/env bash
set -euo pipefail

RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:-/data/data/com.termux/files/home}"
PREFIX_DIR="${PREFIX:-/data/data/com.termux/files/usr}"
TERMUX_DIR="$HOME_DIR/.termux"
BASHRC="$HOME_DIR/.bashrc"
PROPS="$TERMUX_DIR/termux.properties"
COLORS="$TERMUX_DIR/colors.properties"
BACKUP_DIR="$HOME_DIR/.termux-rice-backup/$(date +%Y%m%d-%H%M%S)"
START_MARKER="# >>> termux-rice >>>"
END_MARKER="# <<< termux-rice <<<"

log() {
  printf '%s\n' "$*"
}

backup_file() {
  local file="$1"
  if [ -e "$file" ]; then
    mkdir -p "$BACKUP_DIR"
    cp -p "$file" "$BACKUP_DIR/$(basename "$file")"
  fi
}

remove_bash_block() {
  local tmp
  tmp="$(mktemp)"
  awk -v start="$START_MARKER" -v end="$END_MARKER" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$BASHRC" > "$tmp"
  mv "$tmp" "$BASHRC"
}

set_property() {
  local key="$1"
  local value="$2"
  local tmp
  tmp="$(mktemp)"
  awk -v key="$key" -v line="$key = $value" '
    BEGIN { done = 0 }
    $0 ~ "^[[:space:]]*#?[[:space:]]*" key "[[:space:]]*=" {
      if (!done) {
        print line
        done = 1
      }
      next
    }
    { print }
    END {
      if (!done) {
        print line
      }
    }
  ' "$PROPS" > "$tmp"
  mv "$tmp" "$PROPS"
}

set_extra_keys() {
  local line1="extra-keys = [['ESC','/','-','TAB','UP','DRAWER','PASTE'], \\"
  local line2="               ['HOME','CTRL','ALT','LEFT','DOWN','RIGHT','KEYBOARD']]"
  local tmp
  tmp="$(mktemp)"
  awk -v line1="$line1" -v line2="$line2" '
    BEGIN { done = 0; skip = 0 }
    skip {
      if ($0 ~ /\\[[:space:]]*$/) {
        next
      }
      skip = 0
      next
    }
    /^[[:space:]]*extra-keys[[:space:]]*=/ {
      if (!done) {
        print line1
        print line2
        done = 1
      }
      if ($0 ~ /\\[[:space:]]*$/) {
        skip = 1
      }
      next
    }
    { print }
    END {
      if (!done) {
        print ""
        print line1
        print line2
      }
    }
  ' "$PROPS" > "$tmp"
  mv "$tmp" "$PROPS"
}

log "Creating backups in $BACKUP_DIR"
backup_file "$BASHRC"
backup_file "$PROPS"
backup_file "$COLORS"
backup_file "$HOME_DIR/.hushlogin"

mkdir -p "$TERMUX_DIR"
touch "$BASHRC"

if command -v dpkg-query >/dev/null 2>&1 && ! dpkg-query -W bash-completion >/dev/null 2>&1; then
  if command -v pkg >/dev/null 2>&1; then
    log "Installing bash-completion"
    pkg install -y bash-completion
  else
    log "pkg not found; skipping bash-completion install"
  fi
fi

log "Updating $BASHRC"
remove_bash_block
{
  printf '\n'
  cat "$RICE_DIR/bash/bashrc.termux-rice"
  printf '\n'
} >> "$BASHRC"

log "Writing Base16 Brewer colors"
cp "$RICE_DIR/termux/colors.properties" "$COLORS"

if [ ! -f "$PROPS" ]; then
  printf '# Termux properties\n' > "$PROPS"
fi

log "Applying Termux properties"
set_property "default-working-directory" "/storage/emulated/0"
set_property "terminal-transcript-rows" "8000"
set_property "terminal-cursor-blink-rate" "0"
set_property "terminal-cursor-style" "bar"
set_extra_keys
set_property "use-black-ui" "true"
set_property "terminal-margin-horizontal" "2"
set_property "terminal-margin-vertical" "0"

log "Creating quiet login marker"
: > "$HOME_DIR/.hushlogin"

if command -v termux-reload-settings >/dev/null 2>&1; then
  log "Reloading Termux settings"
  termux-reload-settings || true
fi

log "Done. Run 'source ~/.bashrc' or open a new Termux session."
