#!/bin/bash
# add a user with the default password

[[ -e /var/local/status/verbose ]] && set -x && set -v


grouplist="adm,dialout,cdrom,floppy,audio,dip,video,plugdev,lxd,sudo"
