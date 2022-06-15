#!/bin/bash

apt -y update 
set -x 
set -v 
[[ $(which git) ]] && apt -y reinstall git || apt -y install git 
mkdir -p /usr/local/share/data/GitHub/econ-ark 
[[ ! -e /usr/local/share/data/GitHub/econ-ark/econ-ark-tools ]] && sudo git clone --depth 1 --branch Make-Installer-ISO-WORKS https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target 
cd /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
chmod -Rf a+rwx * ./.*[0-z]* 
rm -Rf /var/local 
\ ln -s /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target /var/local 
touch /etc/rc.local 
mv /etc/rc.local /etc/rc.local_orig 
cp /var/local/rc.local /etc/rc.local 
df -hT > /tmp/target-partition 
cat /tmp/target-partition | grep '/dev' | grep -v 'loop' | grep -v 'ude' | grep -v 'tmpf' | cut -d ' ' -f1 | sed 's/.$//' > /tmp/target-dev 
sd=$(cat /tmp/target-dev) 
rm -f /var/local/Size-To-Make-Is-* 
touch /var/local/Size-To-Make-Is-$(echo MIN) 
echo $(echo MIN > /var/local/About_This_Install/machine-size.txt) 
/bin/bash start.sh 
cp /var/local/Disk/Labels/Econ-ARK.disk_label /Econ-ARK.disk_label 
cp /var/local/Disk/Labels/Econ-ARK.disk_label_2x /Econ-ARK.disk_label_2x 
cp /var/local/Disk/Icons/Econ-ARK.VolumeIcon.icns /Econ-ARK.VolumeIcon.icns 
echo Econ-ARK > /.disk_label.contentDetails
