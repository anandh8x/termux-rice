#!/usr/bin/env bash
set -euo pipefail

HOME_DIR="${HOME:-/data/data/com.termux/files/home}"
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

comment_property() {
  local key="$1"
  local tmp
  [ -f "$PROPS" ] || return 0
  tmp="$(mktemp)"
  awk -v key="$key" '
    $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
      print "# " $0
      next
    }
    { print }
  ' "$PROPS" > "$tmp"
  mv "$tmp" "$PROPS"
}

comment_extra_keys() {
  local tmp
  [ -f "$PROPS" ] || return 0
  tmp="$(mktemp)"
  awk '
    BEGIN { skip = 0 }
    skip {
      print "# " $0
      if ($0 !~ /\\[[:space:]]*$/) {
        skip = 0
      }
      next
    }
    /^[[:space:]]*extra-keys[[:space:]]*=/ {
      print "# " $0
      if ($0 ~ /\\[[:space:]]*$/) {
        skip = 1
      }
      next
    }
    { print }
  ' "$PROPS" > "$tmp"
  mv "$tmp" "$PROPS"
}

log "Creating backups in $BACKUP_DIR"
backup_file "$BASHRC"
backup_file "$PROPS"
backup_file "$COLORS"
backup_file "$HOME_DIR/.hushlogin"

if [ -f "$BASHRC" ]; then
  log "Removing Bash block"
  remove_bash_block
fi

if [ -f "$COLORS" ]; then
  log "Removing theme file"
  rm "$COLORS"
fi

log "Commenting Termux properties"
comment_property "default-working-directory"
comment_property "terminal-transcript-rows"
comment_property "terminal-cursor-blink-rate"
comment_property "terminal-cursor-style"
comment_extra_keys
comment_property "use-black-ui"
comment_property "terminal-margin-horizontal"
comment_property "terminal-margin-vertical"

if [ -f "$HOME_DIR/.hushlogin" ] && [ ! -s "$HOME_DIR/.hushlogin" ]; then
  log "Removing empty .hushlogin"
  rm "$HOME_DIR/.hushlogin"
fi

if command -v termux-reload-settings >/dev/null 2>&1; then
  log "Reloading Termux settings"
  termux-reload-settings || true
fi

log "Done. Open a new Termux session to fully refresh shell settings."
