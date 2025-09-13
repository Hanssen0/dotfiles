CACHE_FILE="/tmp/laptop-touchpad-disabled"

if [ -f "$CACHE_FILE" ] ;then
    rm "$CACHE_FILE"
    sh -c "hyprctl keyword 'device[asuf1208:00-2808:0218-touchpad]:enabled' true"
else
    touch "$CACHE_FILE"
    sh -c "hyprctl keyword 'device[asuf1208:00-2808:0218-touchpad]:enabled' false"
fi
