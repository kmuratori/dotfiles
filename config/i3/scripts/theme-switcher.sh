#!/bin/sh
# ╔══════════════════════════════════════════════════════════════╗
# ║     DARK BEACH — Theme Switcher                              ║
# ║     ~/.config/i3/scripts/theme-switcher.sh                   ║
# ║     Usage: theme-switcher.sh [--random] [--list]             ║
# ╚══════════════════════════════════════════════════════════════╝
# Bind to: $mod+Shift+t in i3 config
# chmod +x ~/.config/i3/scripts/theme-switcher.sh

set -e

# ── PATHS ──────────────────────────────────────────────────────
THEMES_DIR="$HOME/.config/i3/themes"
BACKUP_DIR="$THEMES_DIR/.backup"
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Live config destinations
I3_CONFIG="$HOME/.config/i3/config"
I3BLOCKS_CONFIG="$HOME/.config/i3blocks/config"
PICOM_CONFIG="$HOME/.config/picom/picom.conf"
DUNST_CONFIG="$HOME/.config/dunst/dunstrc"
ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.toml"
ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

# ── HELPERS ────────────────────────────────────────────────────
die() { printf "theme-switcher: error: %s\n" "$*" >&2; exit 1; }
log() { printf "theme-switcher: %s\n" "$*"; }

require_cmd() { command -v "$1" >/dev/null 2>&1 || die "'$1' not found in PATH"; }

backup_active() {
    mkdir -p "$BACKUP_DIR"
    for f in config i3blocks.conf picom.conf dunstrc alacritty-colors.toml rofi-theme.rasi; do
        src="$THEMES_DIR/.active/$f"
        [ -f "$src" ] && cp "$src" "$BACKUP_DIR/$f"
    done
    log "Current theme backed up to $BACKUP_DIR"
}

apply_theme() {
    THEME_DIR="$1"
    [ -d "$THEME_DIR" ] || die "Theme directory not found: $THEME_DIR"

    # Backup active theme first
    backup_active

    # Track what's being applied
    mkdir -p "$THEMES_DIR/.active"

    # Helper: copy if source exists, warn if not
    link_file() {
        src="$THEME_DIR/$1"
        dst="$2"
        if [ -f "$src" ]; then
            mkdir -p "$(dirname "$dst")"
            cp "$src" "$dst"
            cp "$src" "$THEMES_DIR/.active/$1"
            log "Applied: $1 → $dst"
        else
            log "WARNING: $1 not found in theme, skipping"
        fi
    }

    link_file "config"              "$I3_CONFIG"
    link_file "i3blocks.conf"       "$I3BLOCKS_CONFIG"
    link_file "picom.conf"          "$PICOM_CONFIG"
    link_file "dunstrc"             "$DUNST_CONFIG"
    link_file "alacritty-colors.toml" "$ALACRITTY_CONFIG"
    link_file "rofi-theme.rasi"     "$ROFI_CONFIG"

    # Set wallpaper (use first image found in wallpapers/)
    WALL_DIR="$THEME_DIR/wallpapers"
    if [ -d "$WALL_DIR" ]; then
        WALL=$(find "$WALL_DIR" -maxdepth 1 \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | sort | head -1)
        if [ -n "$WALL" ]; then
            feh --no-fehbg --bg-fill "$WALL"
            # Regenerate betterlockscreen cache
            if command -v betterlockscreen >/dev/null 2>&1; then
                betterlockscreen -u "$WALL" >/dev/null 2>&1 &
                log "betterlockscreen cache updating in background…"
            fi
            log "Wallpaper set: $WALL"
        fi
    fi

    # ── RELOAD SERVICES ────────────────────────────────────────
    # Restart picom
    pkill -x picom 2>/dev/null || true
    sleep 0.3
    picom --config "$PICOM_CONFIG" --daemon 2>/dev/null &
    log "picom restarted"

    # Restart dunst
    pkill -x dunst 2>/dev/null || true
    sleep 0.2
    dunst -config "$DUNST_CONFIG" &
    log "dunst restarted"

    # Restart i3blocks
    pkill -x i3blocks 2>/dev/null || true
    log "i3blocks killed (i3 will restart it)"

    # Reload i3
    i3-msg restart >/dev/null 2>&1
    log "i3 reloading…"

    # Notify
    sleep 1
    notify-send --icon=preferences-desktop-theme \
        " Theme Applied" \
        "$(basename "$THEME_DIR")" \
        --urgency=normal 2>/dev/null || true
}

list_themes() {
    find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d \
        ! -name '.backup' ! -name '.active' \
        -exec basename {} \; | sort
}

pick_rofi() {
    require_cmd rofi
    list_themes | rofi \
        -dmenu \
        -p "  theme" \
        -config "$ROFI_CONFIG" \
        -theme-str 'window { width: 360px; }' \
        -format "s" \
        2>/dev/null
}

# ── MAIN ───────────────────────────────────────────────────────
mkdir -p "$THEMES_DIR"

case "${1:-}" in
    --random)
        CHOICE=$(list_themes | shuf -n1)
        [ -z "$CHOICE" ] && die "No themes found in $THEMES_DIR"
        log "Random theme: $CHOICE"
        apply_theme "$THEMES_DIR/$CHOICE"
        ;;
    --list)
        list_themes
        ;;
    --apply)
        [ -z "$2" ] && die "Usage: theme-switcher.sh --apply <theme-name>"
        apply_theme "$THEMES_DIR/$2"
        ;;
    "")
        # Interactive Rofi picker
        require_cmd rofi
        [ "$(list_themes | wc -l)" -eq 0 ] && die "No themes found in $THEMES_DIR"
        CHOICE=$(pick_rofi)
        [ -z "$CHOICE" ] && exit 0
        apply_theme "$THEMES_DIR/$CHOICE"
        ;;
    *)
        printf "Usage: %s [--random | --list | --apply <theme>]\n" "$0"
        exit 1
        ;;
esac
