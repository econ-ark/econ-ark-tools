#!/bin/bash

sudo chown a+x econ-ark-xfce /home/econ-ark-xrdb/.xsession
sudo chmod u+w /etc/xrdp/xrdp.ini
sudo echo "\n[xrdp0]\nname=xubuntark\lib=libvnc.so\username=econ-ark-xrdp\npassword=ask\ip=127.0.0.1\port=5912\n" >> /etc/xrdp/xrdp.ini
sudo service xrdp start
