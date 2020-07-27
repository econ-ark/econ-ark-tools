#!/bin/bash

cd /Volumes/refind-HFS

[[ ! -e refind-bin-0.12.0.zip ]] && curl -L https://sourceforge.net/projects/refind/files/latest/download/0.12.0/refind-bin-0.12.0.zip --output refind.zip && unzip refind.zip

cd refind-bin-0.12.0

locn="$(diskutil list | grep refind-HFS | awk '{print $NF}')"

sudo ./refind-install --ownhfs "/dev/$locn"

sudo bless --setBoot --folder /Volumes/refind-HFS/System/Library/CoreServices --file /Volumes/refind-HFS/System/Library/CoreServices/refind_x64.efi --label "reFind-HFS" --shortform

