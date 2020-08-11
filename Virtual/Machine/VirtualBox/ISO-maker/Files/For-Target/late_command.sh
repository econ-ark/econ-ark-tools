#!/bin/bash
 wget -O /var/local/start.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/start.sh 
 wget -O /etc/rc.local https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/rc.local 
 wget -O /var/local/finish.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/finish.sh 
 wget -O /var/local/finish-MAX-Extras.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/finish-MAX-Extras.sh 
 chmod a+x /var/local/start.sh /var/local/finish.sh /var/local/finish-MAX-Extra.sh /var/local/grub-menu.sh /var/local/late_command.sh 
 touch /var/local/ 
 mkdir -p /usr/share/lightdm/lightdm.conf.d /etc/systemd/system/getty@tty1.service.d 
 wget -O /etc/systemd/system/getty@tty1.service.d/override.conf https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/root/etc/systemd/system/getty@tty1.service.d/override.conf 
 wget -O /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf 
 chmod 755 /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf /etc/systemd/system/getty@tty1.service.d/override.conf
