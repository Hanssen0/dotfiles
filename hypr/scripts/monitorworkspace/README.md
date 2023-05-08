# Monitor workspace

This is a proof of concept of the Awesome WM-liked workspaces on a multi-monitor setup.

With the default settings of Hyprland, all monitors share the same set of workspaces, which forces you to take care of all monitors at the same time.

This helper lets you stay on the same monitor while switching workspaces.

# Features

* Unlimited workspaces per monitor.
* Switch/Move to workspace.
* Switch/Move to monitor.
* No extra configuration for monitors.
* Readable workspace name.
* Workspaces are ordered.

# Todo

* Stop using JS for better performance.
* You tell me.

# Usage

Modify the path of `node` in the [`monitorworkspace.sh`](./monitorworkspace.sh) file.

Make the background service launch with the Hyprland.
```
exec-once = sh ~/.config/hypr/scripts/monitorworkspace/service.sh
```

Replace 
```
bind = $mainMod, 1, workspace, 1

bind = $mainMod SHIFT, 1, movetoworkspace, 1
```
with
```
bind = $mainMod, 1, exec, sh ~/.config/hypr/scripts/monitorworkspace/monitorworkspace.sh workspace 1

bind = $mainMod SHIFT, 1, exec, sh ~/.config/hypr/scripts/monitorworkspace/monitorworkspace.sh movetoworkspace 1
```

To switch/move to a monitor:
```
bind = $mainMod, O, exec, sh ~/.config/hypr/scripts/monitorworkspace/monitorworkspace.sh monitor +1

bind = $mainMod SHIFT, O, exec, sh ~/.config/hypr/scripts/monitorworkspace/monitorworkspace.sh movetomonitor +1
```
It supports both absolute and relative id.
