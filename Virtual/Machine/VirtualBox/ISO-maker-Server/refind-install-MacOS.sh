#!/bin/bash

cd /Volumes/HFS+/

wget https://sourceforge.net/projects/refind/files/latest/download/0.12.0/refind-bin-0.12.0.zip

unzip refind-bin-0.12.0.zip

cd refind-bin-0.12.0

sudo ./refind-install --ownhfs /dev/disk0s2
sudo bless --setBoot --folder /Volumes/HFS+/System/Library/CoreServices --file /Volumes/HFS+/System/Library/CoreServices/refind_x64.efi --label "reFind-HFS+" --shortform
sudo reboot
