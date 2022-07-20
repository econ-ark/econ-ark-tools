#!/bin/bash

build_date="$(</var/local/status/build_date.txt)"

# If preexisting config exists, move it
if [[ -e /var/local/sys_root_dir/etc/ssh/sshd_config ]]; then
    [[ -e /etc/ssh/sshd_config ]] && sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config_$build_date
fi

# Can't run ssh inside chroot; so detect that
inside_chroot=true ; ischroot ; [[ "$?" != 0 ]] && inside_chroot=false

# If ssh might be running, stop it before changing its config
[[ "$inside_chroot" != "true" ]] && [[ "$(ps axuww | grep sshd | grep -v grep)" ]] && sudo service ssh stop

sudo apt -y install openssh-server

# Change the config
sudo cp /var/local/sys_root_dir/etc/ssh/sshd_config /etc/ssh/sshd_config

# Restart ssh 
[[ "$inside_chroot" != "true" ]] && sudo service ssh start

sudo apt -y install sshfs
