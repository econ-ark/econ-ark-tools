#!/bin/bash
# https://int3ractive.com/blog/2018/make-the-best-of-macbook-touchpad-on-ubuntu/
# Update Ubuntu to latest packages
sudo apt update && sudo apt upgrade

# These dependencies were noted by me on default Ubuntu 18.04
sudo apt install build-essential git pkg-config libmtdev-dev mtdev-tools xserver-xorg-dev xutils-dev

# execute line by line:
cd /tmp
git clone https://github.com/p2rkw/xf86-input-mtrack.git
cd xf86-input-mtrack
./configure --with-xorg-module-dir=/usr/lib/xorg/modules
sudo make

sudo touch /usr/share/X11/xorg.conf.d/50-mtrack.conf
sudo chmod a+w /usr/share/X11/xorg.conf.d/50-mtrack.conf

cp /var/local/installers/configure-macbookpro-trackpad-better.config /usr/share/X11/xorg.conf.d/50-mtrack.conf


sudo adduser "`whoami`" input

# install addition dev dependencies for dispad
sudo apt install libconfuse-dev libxi-dev
# get code
cd /tmp

git clone https://github.com/BlueDragonX/dispad.git
cd dispad
# compile the daemon
./configure
make
sudo make install
