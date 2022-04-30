#!/bin/sh
 apt -y update 
 apt -y install git 
 mkdir -p /usr/local/share/data/GitHub/econ-ark /var/local 
 chmod -Rf a+rwx /usr/local/share/data 
 cd /usr/local/share/data/GitHub/econ-ark 
 if [ ! -d econ-ark-tools ]
 then git clone https://github.com/econ-ark/econ-ark-tools 
 fi 
 cd econ-ark-tools 
 git pull 
 git checkout Make-ISO-Installer 
 rm -f /var/local/grub /var/local/rc.local 
 cp -r Virtual/Machine/ISO-maker/Files/For-Target/* /var/local 
 cd /var/local 
 mv /etc/rc.local /etc/rc.local_orig 
 mv rc.local /etc/rc.local 
 ln -s /etc/rc.local 
 mv /etc/default/grub /etc/default/grub_orig 
 mv grub /etc/default/grub 
 ln -s /etc/default/grub 
 chmod 755 /etc/default/grub 
 df -hT > /tmp/target-partition 
 cat /tmp/target-partition | grep /$ | cut -d ' ' -f1 | sed 's/.$//' > /tmp/target-dev 
 sd=$(cat /tmp/target-dev) 
 grub-install $sd
