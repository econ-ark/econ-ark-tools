#!/bin/bash

# Verbose output if file exists
[[ -e /var/local/verbose ]] && set -x && set -v

# rc.local is empty by default
[[ ! -e /etc/rc.local ]] && touch /etc/rc.local 
mv /etc/rc.local /etc/rc.local_orig 
cp /var/local/rc.local /etc/rc.local

# Figure out what the target device is 
df -hT > /tmp/target-partition 
cat /tmp/target-partition | grep '/dev' | grep -v 'loop' | grep -v 'ude' | grep -v 'tmpf' | cut -d ' ' -f1 | sed 's/.$//' > /tmp/target-dev 
sd=$(cat /tmp/target-dev)

# On Macs, this should allow nice icons when disk is viewed
cp /var/local/Disk/Labels/Econ-ARK.disk_label     /Econ-ARK.disk_label 
cp /var/local/Disk/Labels/Econ-ARK.disk_label_2x  /Econ-ARK.disk_label_2x 
cp /var/local/Disk/Icons/Econ-ARK.VolumeIcon.icns /Econ-ARK.VolumeIcon.icns 
echo Econ-ARK > /.disk_label.contentDetails

# Tools that allow machine to recognize many devices without open drivers
# e.g., Broadcom modems are common and require firmware-b43-installer
sudo apt-get -y install b43-fwcutter	       
sudo apt-get -y install firmware-b43-installer

# # /var/local/start.sh |& tee -a /var/local/start-and-finish.log |& tee /var/local/start.log
