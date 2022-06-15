#!/bin/bash

# Get latest versions of everything 
apt -y update 
# Debugging: 
set -x 
set -v 
# Make sure git is installed and up to date 
[[ $(which git) ]] && apt -y reinstall git || apt -y install git 
mkdir -p /usr/local/share/data/GitHub/econ-ark 
[[ ! -e /usr/local/share/data/GitHub/econ-ark/econ-ark-tools ]] && sudo git clone --depth 1 --branch Make-Installer-ISO-WORKS https://github.com/econ-ark/econ-ark-tools //usr/local/share/data/GitHub/econ-ark/ 
# Give repo permissions to be interacted with by users other than root cd /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
chmod -Rf a+rwx * ./.*[0-z]* 
# Hook /var/local into the for-target part of the tools [[ ! -e /var/local ]] && ln -s /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target /var/local 
# Now install rc.local to control boot (after making backup of orig) [[ -e /etc/rc.local ]] && mv /etc/rc.local /etc/rc.local_orig 
cp /var/local/rc.local /etc/rc.local 
# Figure out the target partition for installation df -hT > /tmp/target-partition 
cat /tmp/target-partition | grep '/dev' | grep -v 'loop' | grep -v 'ude' | grep -v 'tmpf' | cut -d ' ' -f1 | sed 's/.$//' > /tmp/target-dev 
sd=$(cat /tmp/target-dev) 
# Indicate which kind of build it is rm -f /var/local/Size-To-Make-Is-* 
touch /var/local/Size-To-Make-Is-$(echo MIN) 
echo $(echo MIN > /var/local/About_This_Install/machine-size.txt) 
/bin/bash start.sh 
# mkdir -p /etc/systemd/system/getty@tty1.service.d 
cp /var/local/Disk/Labels/Econ-ARK.disk_label /Econ-ARK.disk_label 
cp /var/local/Disk/Labels/Econ-ARK.disk_label_2x /Econ-ARK.disk_label_2x 
cp /var/local/Disk/Icons/Econ-ARK.VolumeIcon.icns /Econ-ARK.VolumeIcon.icns 
echo Econ-ARK > /.disk_label.contentDetails
