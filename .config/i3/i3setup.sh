#!/bin/sh

# Applets
nm-applet &

# Do not beep
xset b off

# Switch to workspace 1
i3-msg -t command 'workspace 1'
