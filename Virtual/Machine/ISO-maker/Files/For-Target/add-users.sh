#!/bin/bash

# Presence of 'verbose' triggers bash debugging mode
[[ -e /var/local/verbose ]] && set -x && set -v

grouplist="adm,dialout,cdrom,floppy,audio,dip,video,plugdev,lxd,sudo"

# stackoverflow.com/questions check-whether-a-user-exists
if ! id "ubuntu" &>/dev/null; then # Probably created by seed
    echo 'Creating user ubuntu.'
    sudo useradd --create-home --password "$(perl -e 'print crypt($ARGV[0],"econ-ark")' "kra-noce")" --shell /bin/bash --groups "$grouplist" ubuntu
else # Probably created by multipass
    if ! id econ-ark &>/dev/null; then
	echo 'Creating user econ-ark'
	sudo useradd --create-home --password "$(perl -e 'print crypt($ARGV[0],"econ-ark")' "kra-noce")" --shell /bin/bash --groups "$grouplist" econ-ark
    fi
fi

if ! id econ-ark-xrdp &>/dev/null; then
    echo 'Creating user econ-ark-xrdp'
    sudo useradd --create-home --password "$(perl -e 'print crypt($ARGV[0],"econ-ark")' "kra-noce")" --shell /bin/bash --groups "$grouplist,econ-ark" econ-ark-xrdp
fi
