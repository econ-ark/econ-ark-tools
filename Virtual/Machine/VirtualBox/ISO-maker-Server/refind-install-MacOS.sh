#!/bin/bash
# https://www.rodsbooks.com/refind/
# Canonical solution for how to boot the same (physical) computer under muliple operating systems
# Website has TMI

# Drive named "reFind-HFS" will be mac bootable (at least, without SIP) 
cd /Volumes/refind-HFS

# Latest version as of 20200807; seems to be no way to just specify "latest version"
[[ ! -e refind-bin-0.12.0.zip ]] && curl -L https://sourceforge.net/projects/refind/files/latest/download/0.12.0/refind-bin-0.12.0.zip --output refind.zip && unzip refind.zip

cd refind-bin-0.12.0

# At which /diskXnY is reFind located
locn="$(diskutil list | grep refind-HFS | awk '{print $NF}')"

# Set it up
sudo ./refind-install --ownhfs "/dev/$locn"

# Let MacOS know about it 
sudo bless --setBoot --folder /Volumes/refind-HFS/System/Library/CoreServices --file /Volumes/refind-HFS/System/Library/CoreServices/refind_x64.efi --label "reFind-HFS" --shortform

