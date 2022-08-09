#!/bin/sh


CDDEV="$(mount | grep cdrom | cut -d' ' -f1 | sed 's/\(.*\)./\1/')" 
echo $CDDEV > /tmp/CDDEV 
USBDEV_LIST="/tmp/USBDEV_LIST" 
list-devices usb-partition | sed "s/\(.*\)./\1/" | grep -v "$CDDEV" > "$USBDEV_LIST" 
BOOTDEV_CMD="$(list-devices disk | grep -f "$USBDEV_LIST" | grep -v "$CDDEV" | tail -1)" 
BOOTDEV="$BOOTDEV_CMD"  
echo "$BOOTDEV" > /tmp/BOOTDEV 
echo "BOOTDEV=$BOOTDEV"
if [[ ! "$BOOTDEV" == "" ]]; then \
    echo "BOOTDEV is not empty"
    debconf-set partman-auto/disk "$BOOTDEV" 
    debconf-set partman-auto/select_disk "$BOOTDEV" 	    
    debconf-set grub-installer/bootdev "$BOOTDEV" 
fi 
debconf-set debconf/priority critical
