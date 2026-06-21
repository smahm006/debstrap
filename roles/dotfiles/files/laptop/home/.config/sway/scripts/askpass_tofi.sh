#!/usr/bin/env bash
pass=$(printf "" | tofi -c ~/.config/tofi/fullscreen-config \
  --drun-launch=false --hide-input=true --hidden-char=* \
  --require-match=false --prompt-text="Password:")
[ -z "$pass" ] && exit 1
printf '%s\n' "$pass"
