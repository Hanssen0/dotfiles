# Monitor workspace

This is a proof of concept of the Awesome WM-liked workspaces on a multi-monitor setup.

With the default settings of Hyprland, all monitors share the same set of workspaces, which forces you to take care of all monitors at the same time.

This helper lets you stay on the same monitor while switching workspaces.

# Features

* Unlimited workspaces per monitor.
* Move to workspace.
* Readable workspace name.
* No extra configuration for monitors.
* Workspaces are ordered by its display name.

# Todo

* Stop using JS for better performance.
* A background service listening to monitor events, which maintains the workspace names after monitors changed.
* You tell me.


# Usage

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

If you are using `nvm`, you might need a wrapper for `node` like me. See [monitorworkspace.sh](./monitorworkspace.sh).
