map=(100 65 54 53 35 28 71 36 88 99 55 72 64 38 90 56 63 39 91 50 57 32 67 92 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25)

curr=$(ddcutil -b 21 -t getvcp 10 | cut -d ' ' -f 4)

for i in {0..49}
do
  if [[ ${map[i]} != $curr ]]; then
    continue
  fi

  pos=$(($i * 100 / 49))

  echo '{ "percentage":' "$pos" '}'

  exit
done

