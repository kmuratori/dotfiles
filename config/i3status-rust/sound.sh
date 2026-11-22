#!/bin/sh

s=$(pactl get-default-sink) || exit 0

if pactl get-sink-mute "$s" | grep -q yes
then
  printf '\357\200\246 muted'
else
  v=$(pactl get-sink-volume "$s" | grep -o '[0-9]*%' | head -1)
  printf '\357\200\250 %s' "$v"
fi
