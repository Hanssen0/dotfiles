rx="/tmp/ddcci-21-rx"
tx="/tmp/ddcci-21-tx"
brightness="/tmp/ddcci-21-brightness"

rm -rf $rx
mkfifo $rx

rm -rf $tx
mkfifo $tx

map=(100 65 54 53 35 28 71 36 88 99 55 72 64 38 90 56 63 39 91 50 57 32 67 92 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25)

revMap=()
for i in {0..49}
do
  revMap[map[i]]=$i
done

init=$(ddcutil -b 21 -t getvcp 10 | cut -d ' ' -f 4)
current=$(((revMap[init] * 100 + 48) / 49))

rm -rf $brightness
echo $current > $brightness

trap "kill 0" EXIT
(
  val=${map[current * 49 / 100]}
  previous=$val

  # Update the brightness every one second
  while true; do
    current=$(< $brightness)
    echo "{ \"percentage\": $current }" | dd of=$tx oflag=nonblock status=none
    val=${map[current * 49 / 100]}

    if [ $val != $previous ]; then
      ddcutil -b 21 --noverify setvcp 10 $val > /dev/null

      # If failed to set the brightness, we will try again in the next iteration
      previous=$(ddcutil -b 21 -t getvcp 10 | cut -d ' ' -f 4)
    fi

    sleep 1
  done
) &

while true; do
  echo $current > $brightness
  echo "{ \"percentage\": $current }" | dd of=$tx oflag=nonblock status=none

  read -r cmd < $rx
  case $cmd in
    up)
      current=$(($current + 1))
      ;;
    down)
      current=$(($current + -1))
      ;;
    restore)
      current=$saved
      ;;
    *)
      saved=$current
      current=$cmd
      ;;
  esac

  # 5 <= current <= 100
  current=$(($current>100?100:$current<5?5:$current))
done
