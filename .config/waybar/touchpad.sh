cmd_pipe="/tmp/waybar-touchpad-rx"

if [ $1 ]; then
  echo $1 > $cmd_pipe
  exit
fi

rm -rf $cmd_pipe
mkfifo $cmd_pipe

curr=true
prev=$curr
while true; do
  if [ $curr == "true" ]; then
    echo "{\"alt\":\"enabled\",\"tooltip\":\"Touchpad Enabled\"}"
  else
    echo "{\"alt\":\"disabled\",\"tooltip\":\"Touchpad Disabled\"}"
  fi
  hyprctl keyword 'device[asuf1208:00-2808:0218-touchpad]:enabled' $curr > /dev/null

  read -r cmd < $cmd_pipe
  case $cmd in
      true | false)
          prev=$curr
          curr=$cmd
          ;;
      toggle)
          prev=$curr
          if [ $curr == "true" ]; then
            curr=false
          else
            curr=true
          fi
          ;;
      restore)
          curr=$prev
          ;;
  esac
done
