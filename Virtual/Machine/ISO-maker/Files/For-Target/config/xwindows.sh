#!/bin/bash
# Initial configurations for xwindows

# Repeat keys often does not work well; turn it off
xset r off

# Default xfwm4 compositor is extremely slow; disabling it speeds everything up a lot
xfwm4compositorstatus="$(xfconf-query --channel xfwm4 --property /general/use_compositing --list)"
xfwm4compositorstatusExists="$?"
[[ "$xfwm4compositorstatusExists" == "0" ]] && xfconf-query --channel xfwm4 --property /general/use_compositing --type 'bool' --set false

# Set default geometry
## https://askubuntu.com/questions/453109/add-fake-display-when-no-monitor-is-plugged-in
## https://en.wikipedia.org/wiki/Display_resolution
xrandr --fb 1366x768 
