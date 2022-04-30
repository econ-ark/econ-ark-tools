#!/bin/sh
sudo apt -y update
sudo apt -y install git
sudo mkdir -p /usr/local/share/data/GitHub/econ-ark /var/local
sudo chmod -Rf a+rwx /usr/local/share/data
cd /usr/local/share/data/GitHub/econ-ark
if [ ! -d econ-ark-tools ]; then git clone https://github.com/econ-ark/econ-ark-tools ; fi
cd econ-ark-tools
git pull
cp -r Virtual/Machine/ISO-maker/Files/For-Target/* /var/local
cd /var/local
mv /etc/rc.local /etc/rc.local_orig
mv rc.local /etc/rc.local
ln -s /etc/rc.local
mv /etc/default/grub /etc/default/grub_orig
mv grub /etc/default/grub
ln -s /etc/default/grub
