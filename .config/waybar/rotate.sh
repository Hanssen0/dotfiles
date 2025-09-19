cmd_pipe="/tmp/waybar-rotation-rx"

if [ $1 ]; then
  echo $1 > $cmd_pipe
  exit
fi

rm -rf $cmd_pipe
mkfifo $cmd_pipe

curr=0
while true; do
  if [ $curr == 0 ]; then
    echo "{\"alt\":\"to-portrait\",\"tooltip\":\"To Portrait\"}"
  else
    echo "{\"alt\":\"to-landscape\",\"tooltip\":\"To Landscape\"}"
  fi

  read < $cmd_pipe

  curr=$(($curr==0?1:0))
  hyprctl --batch "keyword monitorv2[DP-3]:transform $curr ; keyword input:touchdevice:transform $curr" > /dev/null
done
