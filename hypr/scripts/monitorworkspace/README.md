# Monitor workspace

This is a proof of concept of the Awesome WM-liked workspaces on a multi-monitor setup.

With the default settings of Hyprland, all monitors share the same set of workspaces, which forces you to take care of all monitors at the same time.

This helper lets you stay on the same monitor while switching workspaces.

# Features

* Unlimited workspaces per monitor.
* Switch/Move to workspace.
* Switch/Move to monitor.
* No extra configuration for monitors.
* Natrual workspace name.
* Workspaces are ordered.

# Todo

* Stop using JS for better performance.
* A background service listening to monitor events, which maintains the workspace names after monitors changed.
* You tell me.

# Usage

Run once at the beginning to initialize workspace names.
```
exec-once = node ~/.config/hypr/scripts/monitorworkspace/monitorworkspace.js
```

Replace 
```
bind = $mainMod, 1, workspace, 1

bind = $mainMod SHIFT, 1, movetoworkspace, 1
```
with
```
bind = $mainMod, 1, exec, node ~/.config/hypr/scripts/monitorworkspace/monitorworkspace.js workspace 1

bind = $mainMod SHIFT, 1, exec, node ~/.config/hypr/scripts/monitorworkspace/monitorworkspace.js movetoworkspace 1
```

To switch/move to a monitor:
```
bind = $mainMod, O, exec, node ~/.config/hypr/scripts/monitorworkspace/monitorworkspace.js monitor +1

bind = $mainMod SHIFT, O, exec, node ~/.config/hypr/scripts/monitorworkspace/monitorworkspace.js movetomonitor +1
```
It supports both absolute and relative id.

If using `nvm`, you might need a wrapper for `node` like me. See [monitorworkspace.sh](./monitorworkspace.sh).
