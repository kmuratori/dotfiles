#!/usr/bin/env bash

MUSIC_DIR="$HOME/media/music"

case "$1" in
  toggle)
    mpc toggle
    ;;
  next)
    mpc next
    ;;
  prev)
    mpc prev
    ;;
  stop)
    mpc stop
    ;;
  artist)
    artist=$(find "$MUSIC_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)
    [[ -z "$artist" ]] && exit 0
    chosen=$(echo "$artist" | dmenu -c -p "🎵 Artist " -g 2 -l 4)
    if [[ -n "$chosen" ]]; then
        mpc -q clear
        mpc -q add "$chosen"
        mpc -q play
        mpc -q repeat on
    fi
    ;;
  album)
    albums=$(find "$MUSIC_DIR" -mindepth 2 -maxdepth 2 -type d \
             -printf "%P\n" | sort)
    [[ -z "$albums" ]] && exit 0
    chosen=$(echo "$albums" | dmenu -c -p "💿 Album " -g 1 -l 8)
    if [[ -n "$chosen" ]]; then
        mpc -q clear
        mpc -q add "$chosen"
        mpc -q play
        mpc -q repeat on
    fi
    ;;
  all)
    mpc -q clear
    mpc -q add /
    mpc -q play
    mpc -q repeat on
    ;;
  *) ;;
esac

pkill -RTMIN+10 i3blocks
