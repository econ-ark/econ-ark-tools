#!/bin/bash

CDDEV="$(mount | grep cdrom | cut -d' ' -f1 | sed 's/\(.*\)./\1/')" 
USBDEV_LIST="/tmp/USBDEV_LIST" 
list-devices usb-partition | sed "s/\(.*\)./\1/" | grep -v "$CDDEV" > "$USBDEV_LIST" 
BOOTDEV="$(list-devices disk | grep -f "$USBDEV_LIST" | grep -v "$CDDEV" | tail -1)" 
echo BOOTDEV="$BOOTDEV"  
echo "$BOOTDEV" > /tmp/BOOTDEV 
if [[ ! -z "$BOOTDEV" ]]; then 
    debconf-set partman-auto/disk "$BOOTDEV" 
    debconf-set grub-installer/bootdev "$BOOTDEV" 
fi 

