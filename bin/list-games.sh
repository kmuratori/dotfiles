#!/usr/bin/env bash
# Rofi script modi: lists installed games. Selecting an entry only closes rofi.
set -euo pipefail

DIRS=(
    "$HOME/.local/share/applications"
    "$HOME/.local/share/flatpak/exports/share/applications"
    "/var/lib/flatpak/exports/share/applications"
    "$HOME/snap/desktop-integration/current/.local/share/applications"
    "/var/lib/snapd/desktop/applications"
    "/usr/local/share/applications"
    "/usr/share/applications"
)

# Prints "name<TAB>icon" if the file is a visible game, nothing otherwise.
parse() {
    awk -F= '
        { sub(/\r$/, "") }
        /^\[/ { entry = ($0 == "[Desktop Entry]"); next }
        !entry { next }
        $1 == "Name" && name == ""  { name = substr($0, 6) }
        $1 == "Icon" && icon == ""  { icon = substr($0, 6) }
        $1 == "Categories"          { cats = ";" substr($0, 12) ";" }
        ($1 == "NoDisplay" || $1 == "Hidden") && $2 == "true" { hide = 1 }
        END {
            if (hide || name == "" || cats !~ /;Game;/) exit
            print name "\t" (icon == "" ? "applications-games" : icon)
        }
    ' "$1"
}

collect() {
    declare -A seen=()
    local dir f name icon
    for dir in "${DIRS[@]}"; do
        [[ -d $dir ]] || continue
        for f in "$dir"/*.desktop; do
            [[ -f $f ]] || continue
            IFS=$'\t' read -r name icon < <(parse "$f") || continue
            [[ -z ${seen[$name]:-} ]] || continue
            seen[$name]=1
            printf '%s\t%s\n' "$name" "$icon"
        done
    done
}

list_games() {
    printf '\0prompt\x1fGames\n\0no-custom\x1ftrue\n'
    collect | sort -f -t$'\t' -k1,1 | while IFS=$'\t' read -r name icon; do
        printf '%s\0icon\x1f%s\n' "$name" "$icon"
    done
}

if [[ $# -eq 0 ]]; then
    list_games
fi
