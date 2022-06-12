#!/bin/bash

set -x 
set -v 
apt -y update 
apt -y install git 
mkdir -p /usr/local/share/data/GitHub/econ-ark 
chmod -Rf a+rwx /usr/local/share/data 
[[ ! -e /usr/local/share/data/GitHub/econ-ark/econ-ark-tools ]] && sudo git clone --branch Make-Installer-ISO-WORKS https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
sudo chmod -Rf a+rw econ-ark-tools 
git config --global --add safe.directory /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
[[ -e /var/local ]] && rm -Rf /var/local 
[[ ! -e /var/local ]] && ln -s /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target /var/local 
cd /var/local 
[[ -e /etc/rc.local ]] && mv /etc/rc.local /etc/rc.local_orig 
cp /var/local/rc.local /etc/rc.local 
df -hT > /tmp/target-partition 
cat /tmp/target-partition | grep '/dev' | grep -v 'loop' | grep -v 'ude' | grep -v 'tmpf' | cut -d ' ' -f1 | sed 's/.$//' > /tmp/target-dev 
sd=$(cat /tmp/target-dev) 
rm -f /var/local/Size-To-Make-Is-* 
touch /var/local/Size-To-Make-Is-$(echo MIN)
# mkdir -p /etc/systemd/system/getty@tty1.service.d 
cp /var/local/Disk/Labels/Econ-ARK.disk_label /Econ-ARK.disk_label 
cp /var/local/Disk/Labels/Econ-ARK.disk_label_2x /Econ-ARK.disk_label_2x 
cp /var/local/Disk/Icons/Econ-ARK.VolumeIcon.icns /Econ-ARK.VolumeIcon.icns 
echo Econ-ARK > /.disk_label.contentDetails
