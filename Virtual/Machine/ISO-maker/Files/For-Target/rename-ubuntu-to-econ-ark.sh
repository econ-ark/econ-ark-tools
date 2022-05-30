#!/bin/bash

# Resources
myuser="econ-ark"  # Don't sudo because it needs to be an environment variable
mypass="kra-noce"  # Don't sudo because it needs to be an environment variable

# stackoverflow.com/questions check-whether-a-user-exists
if id "ubuntu" &>/dev/null; then # Probably created by multipass
    usermod  -l "$myuser" ubuntu
    groupmod -n "$myuser" ubuntu
    usermod  -d /home/"$myuser" -m "$myuser"
    if [ -f /etc/sudoers.d/90-cloudimg-ubuntu ]; then
	/etc/sudoers.d/90-cloud-init-users
    fi
    perl -pi -e "s/ubuntu/$myuser/g;" /etc/sudoers.d/90-cloud-init-users
else
    sudo adduser --disabled-password --gecos "" "$myuser"
fi

sudo chpasswd <<<"$myuser:$mypass"
