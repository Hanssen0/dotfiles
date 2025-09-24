#!/usr/bin/env zsh

source $ZDOTDIR/.zshrc;
nid=$(notify-send -a Gemini -i edit-find -t 30000 -p Gemini "Asking Gemini \"$@\"...");
notify-send -a Gemini -i edit-find -t 30000 -r $nid Gemini "$(gemini -m gemini-2.5-flash -p \"$@\")"
