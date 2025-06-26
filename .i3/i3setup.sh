#!/bin/sh

# Set multi screen layout
xrandr --output DP-2 --auto --primary --output HDMI-1 --auto --right-of DP-2

# Lock screen after 10 minutes of inactivity
xautolock -time 10 -locker 'i3lock --color=000000 --dpms' &

nm-applet &
blueman-applet &
SACMonitor &

# Do not beep
xset b off

# Switch to workspace 1
i3-msg -t command 'workspace 1'
