#!/bin/bash

grouplist="adm,admin,dialout,cdrom,floppy,audio,dip,video,plugdev,netdev,lxd,sudo"

# stackoverflow.com/questions check-whether-a-user-exists
if ! id "ubuntu" &>/dev/null; then # Probably created by seed
    sudo useradd --create-home --password "$(perl -e 'print crypt($ARGV[0],"econ-ark")' "kra-noce")" --shell /bin/bash --groups "$grouplist" econ-ark econ-ark
else # Probably created by multipass
    sudo useradd --create-home --password "$(perl -e 'print crypt($ARGV[0],"econ-ark")' "kra-noce")" --shell /bin/bash --groups "$grouplist" econ-ark ubuntu
fi

sudo useradd --create-home --password "$(perl -e 'print crypt($ARGV[0],"econ-ark")' "kra-noce")" --shell /bin/bash --groups "$grouplist" econ-ark econ-ark-xrdp

