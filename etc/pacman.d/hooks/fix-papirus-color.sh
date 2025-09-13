#!/bin/sh

paths=(/usr/share/icons/Papirus/ /usr/share/icons/Papirus-Dark/)

for path in "${paths[@]}"; do
  echo Fixing $path...
  find $path -type f | xargs sed -i -e "s/.ColorScheme-Text { color:#dfdfdf; }/.ColorScheme-Text { color:#ffffff; }/g"
done

