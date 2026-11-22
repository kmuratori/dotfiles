#!/usr/bin/env bash

status=$(mpc status '%state%' 2>/dev/null)
song=$(mpc current 2>/dev/null)

if [[ -z $song || -z $status ]]
then
  echo '{"text":""}'
  exit 0
fi

case $status in
    playing) icon="▶"; state="Good" ;;
    paused)  icon="⏸"; state="Warning" ;;
    *)       icon="⏹"; state="Idle" ;;
esac

jq -nc --arg t "$icon $song" --arg s "$state" '{text:$t, state:$s}'
