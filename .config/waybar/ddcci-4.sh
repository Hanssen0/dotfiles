cmd_pipe="/tmp/waybar-ddcci-4-rx"
brightness="/tmp/waybar-ddcci-4-brightness"

curr=$(ddcutil -b 4 -t getvcp 10 | cut -d ' ' -f 4)

rm -rf $cmd_pipe
mkfifo $cmd_pipe

rm -rf $brightness
echo $curr > $brightness

trap "kill 0" EXIT
(
  prev=$curr
  while true; do
    curr=$(< $brightness)

    if [ $curr != $prev ]; then
        ddcutil -b 4 --noverify setvcp 10 $curr > /dev/null
        prev=$curr
    fi
    sleep 1
  done
) &

while true; do
    echo $curr > $brightness
    echo '{ "percentage":' "$curr" '}'

    read -r cmd < $cmd_pipe
    case $cmd in
        up)
            curr=$(($curr + 1))
            ;;
        down)
            curr=$(($curr + -1))
            ;;
        restore)
            curr=$saved
            ;;
        *)
            saved=$curr
            curr=$cmd
            ;;
    esac
    curr=$(($curr>100?100:$curr<0?0:$curr))
done
