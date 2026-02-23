rx="/tmp/ddcci-4-rx"
tx="/tmp/ddcci-4-tx"
brightness="/tmp/ddcci-4-brightness"

rm -rf $rx
mkfifo $rx

rm -rf $tx
mkfifo $tx

current=$(ddcutil -b 4 -t getvcp 10 | cut -d ' ' -f 4)

rm -rf $brightness
echo $current > $brightness

trap "kill 0" EXIT
(
  previous=$current

  # Update the brightness every one second
  while true; do
    current=$(< $brightness)
    echo "{ \"percentage\": $current }" | dd of=$tx oflag=nonblock status=none

    if [ $current != $previous ]; then
      ddcutil -b 4 --noverify setvcp 10 $current > /dev/null

      # If failed to set the brightness, we will try again in the next iteration
      previous=$(ddcutil -b 4 -t getvcp 10 | cut -d ' ' -f 4)
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

  # 0 <= current <= 100
  current=$(($current>100?100:$current<0?0:$current))
done
