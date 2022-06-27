#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo 'usage: install-emacs.sh [username]'
    exit
fi


# If our sshd_conf is different from one in /etc/sshd_config ...
# diff /var/local/root/etc/ssh/sshd_config /etc/sshd_config > /dev/null
# ... then it's because this is the first time we're running the script
# ... so install the openssh-server
#[[ "$?" != 0 ]] && sudo apt -y install openssh-server

# Create a public key for security purposes
if [[ ! -e /home/$myuser/.ssh ]]; then
    mkdir -p /home/$myuser/.ssh
    chown $myuser:$myuser /home/$myuser/.ssh
    chmod 700 /home/$myuser/.ssh
    sudo -u $myuser ssh-keygen -t rsa -b 4096 -q -N "" -C $myuser@XUBUNTU -f /home/$myuser/.ssh/id_rsa
fi    

build_date="$(<build_date.txt)"
# Enable public key authentication
cd /var/local
[[ -e root/etc/ssh/sshd_config ]] && sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_$build_date
sudo cp root/etc/ssh/sshd_config /etc/ssh/sshd_config

