#!/bin/bash

apt -y update 
apt -y reinstall git 
mkdir -p /usr/local/share/data/GitHub/econ-ark 
[[ ! -e /usr/local/share/data/GitHub/econ-ark/econ-ark-tools ]] && git clone --depth 1 --branch Make-Installer-ISO-WORKS https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
chmod -R a+rwx /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/* /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/.*[0-z]* 
[[ -d /var/local ]] && rm -Rf /var/local 
if [[ ! -L /var/local ]]
then rm -Rf /var/local 
ln -s /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target /var/local 
fi 
touch /etc/rc.local 
mv /etc/rc.local /etc/rc.local_orig 
cp /var/local/rc.local /etc/rc.local 
df -hT > /tmp/target-partition 
cat /tmp/target-partition | grep '/dev' | grep -v 'loop' | grep -v 'ude' | grep -v 'tmpf' | cut -d ' ' -f1 | sed 's/.$//' > /tmp/target-dev 
sd=$(cat /tmp/target-dev) 
rm -f /var/local/Size-To-Make-Is-* 
touch /var/local/Size-To-Make-Is-$(echo MIN) 
echo $(echo MIN > /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target/About_This_Install/machine-size.txt) 
cp /var/local/Disk/Labels/Econ-ARK.disk_label /Econ-ARK.disk_label 
cp /var/local/Disk/Labels/Econ-ARK.disk_label_2x /Econ-ARK.disk_label_2x 
cp /var/local/Disk/Icons/Econ-ARK.VolumeIcon.icns /Econ-ARK.VolumeIcon.icns 
echo Econ-ARK > /.disk_label.contentDetails
(set -x 
set -v 
/var/local/start.sh |& tee -a /var/local/start-and-finish.log |& tee /var/local/start.log )
