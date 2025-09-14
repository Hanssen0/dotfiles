#!/usr/bin/env sh

if [[ "$@" == "gemini" ]]; then
  coproc (~/.config/rofi/scripts/ask-gemini.zsh "$ROFI_INPUT")
  exit 0
fi

echo -en "gemini\0display\x1fAsk Gemini\x1fpermanent\x1ftrue\x1ficon\x1fedit-find\n"
