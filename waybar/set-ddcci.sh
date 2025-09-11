if [ -z "$1" ]; then
  prev=$(< /tmp/ddcci-brightness)
  ddcutil -b 21 --noverify setvcp 10 $prev > /dev/null
  exit
fi

map=(100 65 54 53 35 28 71 36 88 99 55 72 64 38 90 56 63 39 91 50 57 32 67 92 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25)

curr=$(ddcutil -b 21 -t getvcp 10 | cut -d ' ' -f 4)
echo $curr > /tmp/ddcci-brightness

for i in {0..49}
do
  if [[ ${map[i]} != $curr ]]; then
    continue
  fi

  sign=${1:0:1}
  if [[ $sign == "+" ||  $sign == "-" ]]; then
    next=$(($i + $1))
  else
    next=$1
  fi

  final=$(($next>49?49:$next<0?0:$next))

  ddcutil -b 21 --noverify setvcp 10 $((map[final])) > /dev/null

  exit
done
