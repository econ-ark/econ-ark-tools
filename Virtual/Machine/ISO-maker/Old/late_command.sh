#!/bin/bash

online=https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker
startFile="start.sh"
finishFile="finish.sh"
seed_file="econ-ark.seed"
ks_file=ks.cfg
rclocal_file=rc.local

sudo wget -r --output-document=/var/local/start.sh  $online/$startFile   ;\
sudo wget -r --output-document=/var/local/finish.sh $online/$finishFile ;\
sudo wget -r --output-document=/etc/rc.local        $online/$rclocal_file ;\ 
sudo chmod +x /var/local/start.sh ;\
sudo chmod +x /var/local/finish.sh ;\
sudo chmod +x /etc/rc.local ;\
sudo mkdir -p /etc/lightdm/lightdm.conf.d ;\
sudo wget -r --output-document=/etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf $online/root/etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf ;\
sudo chmod 755 /etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf 
sudo apt -y install refind




# curl -L -o /var/local/start.sh  $online/$startFile     ;\
# curl -L -o /var/local/finish.sh $online/$finishFile    ;\
# curl -L -o /etc/rc.local        $online/$rclocal_file  ;\
# chmod +x /var/local/start.sh ;\
# chmod +x /var/local/finish.sh ;\
# chmod +x /etc/rc.local ;\
# mkdir -p /etc/lightdm/lightdm.conf.d ;\
# curl -L -o /etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf $online/root/etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf ;\
# chmod 755 /etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf

