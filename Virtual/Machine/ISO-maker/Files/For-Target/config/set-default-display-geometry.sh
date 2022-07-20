#!/bin/bash

# Set default geometry
## https://askubuntu.com/questions/453109/add-fake-display-when-no-monitor-is-plugged-in
## https://en.wikipedia.org/wiki/Display_resolution

if [[ "$(which lshw)" ]] && vbox="$(lshw 2>/dev/null | grep VirtualBox)"  && [[ "$vbox" != "" ]]; then
    xrandr --fb 1366x768
fi

