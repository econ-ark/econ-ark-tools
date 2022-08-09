#!/bin/sh


CDDEV="$(mount | grep cdrom | tail -1 | cut -d' ' -f1 | sed 's/\(.*\)./\1/')" 
echo $CDDEV > /tmp/CDDEV 
list-devices usb-partition | sed "s/\(.*\)./\1/" | grep -v "$CDDEV" > /tmp/USBDEV_LIST 
BOOTDEV_CMD="list-devices disk | grep -f /tmp/USBDEV_LIST | grep -v "$CDDEV" | tail -1" 
echo BOOTDEV_CMD="$BOOTDEV_CMD" 
BOOTDEV="$(eval $BOOTDEV_CMD)"  
echo "$BOOTDEV" > /tmp/BOOTDEV 
echo "BOOTDEV=$BOOTDEV"
if [[ ! "$BOOTDEV" == "" ]]; then \
    echo "BOOTDEV is not empty"
    debconf-set partman-auto/disk "$BOOTDEV" 
    debconf-set partman-auto/select_disk "$BOOTDEV" 	    
    debconf-set grub-installer/bootdev "$BOOTDEV" 
fi 
debconf-set debconf/priority critical
