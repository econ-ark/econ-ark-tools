#!/bin/bash
# Initial configurations for xwindows

flag=/var/local/status/xfwmcompositor-off.flag
if [[ ! -e "$flag" ]]; then
    # Default xfwm4 compositor is extremely slow; disabling it speeds everything up a lot
    xfwm4compositorstatus="$(xfconf-query --channel xfwm4 --property /general/use_compositing --list)"
    xfwm4compositorstatusExists="$?"
    [[ "$xfwm4compositorstatusExists" == "0" ]] && xfconf-query --channel xfwm4 --property /general/use_compositing --type 'bool' --set false
    touch "$flag"
fi

