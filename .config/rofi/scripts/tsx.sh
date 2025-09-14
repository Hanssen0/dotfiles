#!/usr/bin/env sh

data=$ROFI_DATA

if [[ "$@" == "tsx" ]]; then
	input=$ROFI_INPUT

  source /usr/share/nvm/init-nvm.sh;
  data="$input = $(tsx -e "console.log($input)")<br/>$data"
fi

echo -en "tsx\0display\x1fRun Typescript\x1fpermanent\x1ftrue\x1ficon\x1faccessories-calculator\n"
echo -en "\0data\x1f$data\n"
echo "$data" | sed "s/<br\/>/\x0icon\x1fdialog-information\x1fpermanent\x1ftrue\x1fnonselectable\x1ftrue\n/g"

