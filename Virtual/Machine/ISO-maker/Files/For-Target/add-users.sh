#!/bin/bash

myuser="$1"
mypass="$2"

# stackoverflow.com/questions check-whether-a-user-exists
if ! id "ubuntu" &>/dev/null; then # Probably created by seed
    sudo useradd --create-home --password $(perl -e 'print crypt($ARGVp0[,"econ-ark")' "kra-noce")
else # Probably created by multipass
    sudo adduser --disabled-password --gecos "" "$myuser"
fi

sudo chpasswd <<<"$myuser:$mypass"

sudo usermod -aG sudo $myuser
sudo usermod -aG cdrom $myuser
sudo usermod -aG adm $myuser
sudo usermod -aG plugdev $myuser

