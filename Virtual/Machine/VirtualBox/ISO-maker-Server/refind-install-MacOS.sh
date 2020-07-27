#!/bin/bash

cd /Volumes/refind-HFS

[[ ! -e refind-bin-0.12.0.zip ]] && wget https://sourceforge.net/projects/refind/files/latest/download/0.12.0/refind-bin-0.12.0.zip && unzip refind-bin-0.12.0.zip

cd refind-bin-0.12.0

# Figure out what to replace /dev/disk0s2 with 
# sudo ./refind-install --ownhfs /dev/disk0s2

# sudo bless --setBoot --folder /Volumes/HFS+/System/Library/CoreServices --file /Volumes/HFS+/System/Library/CoreServices/refind_x64.efi --label "reFind-HFS" --shortform

# sudo reboot
