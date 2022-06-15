#!/bin/bash

# Make an ISO of the installation medium

blkid /dev/sr0
if [[ "$?" == 0 ]]; then # there is something there
    # get its label
    LBL=$(blkid /dev/sr0 | cut -f2 -d':' | cut -f2 -d'=' | cut -f1 -d' ')
    if [[ "$LBL" != "" ]]; then # It has a label
	dd if=/dev/sr0 of=/var/local/installers/$LBL.iso bs=2048 count=425426 status=progress
    else
	dd if=/dev/sr0 of=/var/local/installers/CDROM.iso bs=2048 count=425426 status=progress
    fi
fi

