#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo 'usage: config-emacs.sh [username]'
    exit
fi

myuser=$1

[[ -e /var/local/status/verbose ]] && set -x && set -v

[[ ! -e /root/.emacs.d ]] && echo 'First run installers/install-emacs.sh to create root setup' && exit

localhome=var/local/root/home # templates

## Create .emacs files
[[ -e /home/$myuser/.emacs ]] && mv /home/$myuser/.emacs /home/$myuser/.emacs_orig
rm -f /home/$myuser/.emacs
cp /$localhome/user_regular/dotemacs-regular-users /home/$myuser/.emacs

# Create .emacs.d directory with proper permissions -- avoids annoying startup warning msg
[[ -e /home/$myuser/.emacs.d ]] && mv /home/$myuser/.emacs.d_orig

# Don't install the packages twice - instead, link root to the existing install
[[ -e /root/.emacs.d ]] && ln -s /root/.emacs.d /home/$myuser/.emacs.d 

# Do emacs first-time setup
emacs -batch --eval "(setq debug-on-error t)" -l     /home/$myuser/.emacs  

# Finished with emacs
