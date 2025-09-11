#!/bin/sh

BASEDIR=$(dirname $0)
function handle {
  if [[ ${1:0:7} == "monitor" ]]; then
    sh $BASEDIR/monitorworkspace.sh
  fi
}

sh $BASEDIR/monitorworkspace.sh
socat "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" stdout | while read -r line; do handle "$line"; done
