#!/bin/bash
curl -L -o /var/local/late_command.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker-Server/late_command.sh 
curl -L -o /var/local/start.sh   https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker-Server/Files/For-Target/Files/For-Target/start.sh 
curl -L -o /var/local/finish.sh  https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker-Server/Files/For-Target/Files/For-Target/finish.sh 
curl -L -o /var/local/Files/For-Target/finish-MAX-Extras.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker-Server/Files/For-Target/Files/For-Target/finish-MAX-Extras.sh 
curl -L -o /etc/rc.local    https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker-Server/Files/For-Target/Files/For-ISO/rc.local 
chmod +x /var/local/start.sh /var/local/finish.sh /etc/rc.local /var/local/Files/For-Target/finish-MAX-Extras.sh 
mkdir -p   /usr/share/lightdm/lightdm.conf.d 
curl -L -o /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf  https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker-Server/Files/For-Target/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf 
chmod 755  /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf 
