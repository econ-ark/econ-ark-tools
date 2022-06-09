#!/bin/bash

DATE="$(stat -c %z /proc)"
size="$(/var/local/About_This_Install/machine-size.txt)"
hostdate="xubark-$(printf %s `date -d"$DATE" +%Y%m%d%H%M`)"
sudo hostname "$hostdate"
sudo echo "$hostdate" > /etc/hostname
