#!/bin/bash
 wget -O /var/local/start.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/start.sh 
 wget -O /etc/rc.local https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/rc.local 
 wget -O /var/local/finish.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/finish.sh 
 wget -O /var/local/finish-MAX-Extras.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/finish-MAX-Extras.sh 
 wget -O /var/local/grub-menu.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/grub-menu.sh 
 chmod a+x /var/local/start.sh /var/local/finish.sh /var/local/finish-MAX-Extra.sh /var/local/grub-menu.sh /var/local/late_command.sh 
 chmod a+x /etc/rc.local 
 touch /var/local/ 
 mkdir -p /usr/share/lightdm/lightdm.conf.d /etc/systemd/system/getty@tty1.service.d 
 wget -O /etc/systemd/system/getty@tty1.service.d/override.conf https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/root/etc/systemd/system/getty@tty1.service.d/override.conf 
 chmod 755 /etc/systemd/system/getty@tty1.service.d/override.conf
