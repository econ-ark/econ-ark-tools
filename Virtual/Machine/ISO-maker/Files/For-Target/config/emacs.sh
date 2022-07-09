#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo 'usage: config-emacs.sh [username]'
    exit
fi

myuser=$1

[[ -e /var/local/status/verbose ]] && set -x && set -v


localhome=var/local/root/home # templates

## Create .emacs files
[[ -e /home/$myuser/.emacs ]] && mv /home/$myuser/.emacs /home/$myuser/.emacs_orig
rm -f /home/$myuser/.emacs
cp /$localhome/user_regular/dotemacs-regular-users /home/$myuser/.emacs
    
# Create .emacs.d directory with proper permissions -- avoids annoying startup warning msg
[[ ! -e /home/$myuser/.emacs.d ]] && mkdir /home/$myuser/.emacs.d && chown "$myuser:$myuser" /home/$myuser/.emacs.d

# Do emacs first-time setup (including downloading packages)
emacs -batch -l     /home/$myuser/.emacs  

# Don't install the packages twice - instead, link root to the existing install
[[ -e /root/.emacs.d ]] && ln -s /home/$myuser/.emacs.d /root/.emacs.d

# Do emacs first-time setup (including downloading packages)
emacs -batch --eval "(setq debug-on-error t)" -l     /home/$myuser/.emacs  

# Finished with emacs
