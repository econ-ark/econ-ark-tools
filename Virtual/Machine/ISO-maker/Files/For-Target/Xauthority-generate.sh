#!/bin/bash

HOST=$1
myuser=$2

# Get the MIT-MAGIC-COOKIE from the running instance, add the new HOST,
magic="$(sudo xauth -f /var/run/lightdm/root/:0 list | awk '{print $NF}')"
[[ ! -e /root/.Xauthority ]] && sudo touch /root/.Xauthority  
sudo xauth -vf /root/.Xauthority add $HOST/unix:0 . "$magic"
# Merge so that either the old or the new HOST should work
sudo xauth -v merge /var/run/lightdm/root/:0 /root/.Xauthority
sudo cp /root/.Xauthority /home/$myuser/.Xauthority
# Give them the required permissions
sudo chmod a-rwx /root/.Xauthority
sudo cp /root/.Xauthority /home/$myuser/.Xauthority
#    sudo chmod u+rw /root/.Xauthority
# askubuntu.com/questions/253376/lightdm-failed-during-authentication
# Says permissions should be 664 (or maybe 666)
sudo chown $myuser:$myuser /home/$myuser/.Xauthority
sudo chmod 664             /home/$myuser/.Xauthority
