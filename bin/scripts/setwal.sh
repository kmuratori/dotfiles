#!/bin/dash

set_wp()
{
	feh --bg-fill "$1"
	pkill betterlockscreen > /dev/null 2>&1
	notify-send -a "Wallpaper" "wallpaper changed to $(basename $1)" -i "$1" -t 5000
	nohup betterlockscreen -u "$1" --fx dim > /dev/null 2>&1 &
}

[ $# -eq 1 ] && [ -f "$1" ] && set_wp "$1" && exit 0

selected_wp=$(find "$WALLPAPERS_PATH" -type f -exec basename {} \; | dmenu -i -p "󰸉 ")
[ -n "$selected_wp" ] && set_wp "$WALLPAPERS_PATH/$selected_wp" && exit 0
