#!/bin/sh

CDDEV="$(mount | grep cdrom | cut -d' ' -f1 | sed 's/\(.*\)./\1/')" 
USBDEV_LIST="/tmp/USBDEV_LIST" 
list-devices usb-partition | sed "s/\(.*\)./\1/" | grep -v "$CDDEV" > "$USBDEV_LIST" 
BOOTDEV_CMD="$(list-devices disk | grep -f "$USBDEV_LIST" | grep -v "$CDDEV" | tail -1)" 
BOOTDEV="$BOOTDEV_CMD"
echo "$BOOTDEV" > /tmp/BOOTDEV 
if [[ ! "$BOOTDEV" == "" ]]; then 
    debconf-set partman-auto/disk "$BOOTDEV" 
    debconf-set grub-installer/bootdev "$BOOTDEV" 
fi 

