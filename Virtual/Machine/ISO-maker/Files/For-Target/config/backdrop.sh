#!/bin/bash

# Presence of 'verbose' triggers bash debugging mode
[[ -e /var/local/status/verbose/backdrop ]] && set -x && set -v && verbose=true

/var/local/config/backdrop-background-copy-Econ-ARK.sh

# Document, in /var/local, where its content is used
## preserve the original

# Wait for the monitor to be active before configuring it 
monitor=""
slept=0
give_up_after_seconds=20
[[ "$verbose" == true ]] && echo ''
while [[ ( "$monitor" == "" && $slept -le $give_up_after_seconds ) ]] ; do 
    [[ "$verbose" == true ]] && [[ "$selpt" -ge 1 ]] && echo 'Waiting for monitor to come up ...'
    cmd="$(xrandr --listactivemonitors | tail -n 1 | rev | cut -d' ' -f1 | rev)"
    monitor="$cmd" > /dev/null
    sleep 1
    slept="$(($slept+1))"
done

[[ "$verbose" == true ]] && echo "monitor=$monitor" && echo ''

# If running on virtualbox, xrandr --listactivemonitors returns 'default' but should return 0
[[ "$monitor" == "default" ]] && monitor=0 

monitorPath="/backdrop/screen0/monitor$monitor" # Get the property name of the monitor
# Set backdrop for both the monitor and the workspace
#xfconf-query --channel xfce4-desktop --property "$monitorPath/image-path"             --set /usr/share/xfce4/backdrops/Econ-ARK-Logo-1536x768.jpg
xfconf-query --channel xfce4-desktop --property "$monitorPath/workspace0/last-image"  --set /usr/share/xfce4/backdrops/Econ-ARK-Logo-1536x768.jpg
#xfconf-query --channel xfce4-desktop --property "$monitorPath/image-style"            --set 4 # Scaling
xfconf-query --channel xfce4-desktop --property "$monitorPath/workspace0/image-style" --set 4 # Scaling

# Set background to black (rgba1 property of the monitor and workspace)
# black="--type double --set 0.0 --type double --set 0.0 --type double --set 0.0 --type double --set 1.0" 
# For some bizarre reason, can't use "$black" shell variable defined above
# in the command, so spell it out:
xfconf-query              --channel xfce4-desktop --property "$monitorPath/rgba1"            --type double --set 0.0 --type double --set 0.0 --type double --set 0.0 --type double --set 1.0 &> /dev/null
if [[ $? != 0 ]]; then # the rgb property did not exist - so create it 
    xfconf-query --create --channel xfce4-desktop --property "$monitorPath/rgba1"            --type double --set 0.0 --type double --set 0.0 --type double --set 0.0 --type double --set 1.0
fi

xfconf-query              --channel xfce4-desktop --property "$monitorPath/workspace0/rgba1" --type double --set 0.0 --type double --set 0.0 --type double --set 0.0 --type double --set 1.0 &> /dev/null
if [[ $? != 0 ]]; then # the rgb property did not exist - so create it 
    xfconf-query --create --channel xfce4-desktop --property "$monitorPath/workspace0/rgba1" --type double --set 0.0 --type double --set 0.0 --type double --set 0.0 --type double --set 1.0
fi

