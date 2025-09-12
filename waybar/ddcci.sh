cmd_pipe="/tmp/waybar-ddcci-rx"
brightness="/tmp/waybar-ddcci-brightness"
map=(100 65 54 53 35 28 71 36 88 99 55 72 64 38 90 56 63 39 91 50 57 32 67 92 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25)

revMap=()
for i in {0..49}
do
  revMap[map[i]]=$i
done

init=$(ddcutil -b 21 -t getvcp 10 | cut -d ' ' -f 4)
curr=$(((revMap[init] * 100 + 48) / 49))

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
        ddcutil -b 21 --noverify setvcp 10 ${map[curr * 49 / 100]} > /dev/null
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
    curr=$(($curr>100?100:$curr<5?5:$curr))
done
