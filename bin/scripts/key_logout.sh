#! /usr/bin/env bash

set -xe

OPT=$1

if [ -z $OPT ]
then
  OPT=$(printf "lock\nlightsoff\nlogout\nreboot\npoweroff" | dmenu -p "?")
fi

case $OPT in
  "lock"      ) betterlockscreen -l dim ;;
  "logout"    ) i3-msg exit             ;;
  "reboot"    ) loginctl reboot         ;;
  "poweroff"  ) loginctl poweroff       ;;
  "lightsoff" ) brightnessctl set 0%=   ;;
  *           ) ;;
esac

