#!/bin/bash
curl -L -o /var/local/start.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker-Server/start.sh 
curl -L -o /var/local/finish.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker-Server/finish.sh 
curl -L -o /etc/rc.local https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker-Server/rc.local 
chmod +x /var/local/start.sh 
chmod +x /var/local/finish.sh 
chmod +x /etc/rc.local 
mkdir -p /etc/lightdm/lightdm.conf.d 
curl -L -o /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf  https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker-Server/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf 
apt -y install xubuntu-desktop 
\ 
apt -y install xfce4 
\ 
