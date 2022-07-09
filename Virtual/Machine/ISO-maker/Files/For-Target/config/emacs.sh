#!/bin/bash
# Assumes emacs has already been installed by ./install-emacs.sh

if [[ "$#" -ne 1 ]]; then
    echo 'usage: config-emacs.sh [username]'
    exit
fi

[[ -e /var/local/status/verbose ]] && set -x && set -v
myuser=$1

shared=/usr/local/share/emacs
myhome=/home/$myuser

[[ ! -e $shared//.emacs.d ]] && echo 'First run installers/install-emacs.sh to create root setup' && exit

localhome=var/local/root/home # templates

install_time="$(date +%Y%m%d%H%M)"
date_commit="$(</var/local/status/date_commit)"
## Create .emacs files
[[ -e /home/$myuser/.emacs ]] && mv /home/$myuser/.emacs /home/$myuser/.emacs_orig_$install_time
rm -f /home/$myuser/.emacs
cp /$localhome/user_regular/dotemacs-regular-users /home/$myuser/.emacs
ln -s /$localhome/user_regular/dotemacs-regular-users /home/$myuser/.emacs_econ-ark_$date_commit

# Create .emacs.d directory with proper permissions -- avoids annoying startup warning msg
[[ -e /home/$myuser/.emacs.d ]] && mv /home/$myuser/.emacs.d_$install_time

# Don't install packages separately for each user - instead, link root to the existing install
[[ -e $shared/.emacs.d ]] && ln -s $shared/.emacs.d /home/$myuser/.emacs.d 

# Do emacs first-time setup
emacs -batch --eval "(setq debug-on-error t)" -l     /home/$myuser/.emacs  

# Finished with emacs
