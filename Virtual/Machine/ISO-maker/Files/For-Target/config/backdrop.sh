#!/bin/bash

# Wait for the monitor to be active before configuring it 
monitor=""  
while [[ "$monitor" == "" ]] ; do 
    echo 'Waiting for monitor to come up ...'
    cmd="$(xrandr --listactivemonitors | tail -n 1 | rev | cut -d' ' -f1 | rev)"
    echo "$cmd"
    monitor="$cmd" > /dev/null
    sleep 1
done

# If running on virtualbox, xrandr --listactivemonitors returns 'default' but should return 0
[[ "$monitor" == "default" ]] && monitor=0 

monitorPath="/backdrop/screen0/monitor$monitor" # Get the property name of the monitor
# Set backdrop for both the monitor and the workspace
xfconf-query --channel xfce4-desktop --property "$monitorPath/image-path"             --set /usr/share/xfce4/backdrops/Econ-ARK-Logo-1536x768.jpg
xfconf-query --channel xfce4-desktop --property "$monitorPath/workspace0/last-image"  --set /usr/share/xfce4/backdrops/Econ-ARK-Logo-1536x768.jpg
xfconf-query --channel xfce4-desktop --property "$monitorPath/image-style"            --set 4 # Scaling
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

