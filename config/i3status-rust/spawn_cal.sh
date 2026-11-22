#! /usr/bin/env bash
# Spawn a terminal running `cal`

alacritty                          \
  -T calender                      \
  -o window.dimensions.columns=22  \
  -o window.dimensions.lines=10    \
  -e bash                          \
  -c 'cal -m && read' &

disown


