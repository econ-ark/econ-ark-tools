#!/bin/bash
 wget -O /var/local/start.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/start.sh 
 wget -O /etc/rc.local https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/rc.local 
 chmod +x /var/local/start.sh /var/local/finish.sh /etc/rc.local /var/local/finish-MAX-Extras.sh 
 wget -O /var/local/finish.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/finish.sh 
 wget -O /var/local/finish-MAX-Extras.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/finish-MAX-Extras.sh 
 touch /var/local/ 
 mkdir -p /usr/share/lightdm/lightdm.conf.d 
 wget -O /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf 
 chmod 755 /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf
