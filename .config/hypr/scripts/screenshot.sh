hyprctl keyword "decoration:screen_shader" ""
grim -t ppm screenshot.ppm
hyprctl keyword "decoration:screen_shader" "~/.config/hypr/shaders/vibrance.glsl"
satty --filename screenshot.ppm
