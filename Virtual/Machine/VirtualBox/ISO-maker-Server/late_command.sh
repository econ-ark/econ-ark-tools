#!/bin/bash


curl -L -o /var/local/start.sh $online/$startFile ;\
curl -L -o /var/local/finish.sh $online/$finishFile ;\
curl -L -o /etc/rc.local $online/$rclocal_file ;\
chmod +x /var/local/start.sh ;\
chmod +x /var/local/finish.sh ;\
chmod +x /etc/rc.local ;\
mkdir -p /etc/lightdm/lightdm.conf.d ;\
curl -L -o /etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf $online/root/etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf ;\
chmod 755 /etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf

