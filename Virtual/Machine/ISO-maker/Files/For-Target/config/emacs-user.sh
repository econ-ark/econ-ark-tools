#!/bin/bash
# Assumes emacs has already been installed by ./install-emacs.sh

# Presence of 'verbose' triggers bash debugging mode
[[ -e /var/local/status/verbose ]] && set -x && set -v 

if [[ "$#" -ne 1 ]]; then
    echo 'usage: config-emacs.sh [username]'
    exit
fi

[[ -e /var/local/status/verbose ]] && set -x && set -v
myuser=$1

shared=/usr/local/share/emacs
myhome=/home/$myuser

[[ "$myuser" == "root" ]] && myhome=/root

[[ ! -e $shared/.emacs.d ]] && echo 'First run installers/install-emacs.sh to create root setup' && exit

localhome=var/local/sys_root_dir/home # templates

install_time="$(date +%Y%m%d%H%M)"
build_date="$(</var/local/status/build_date.txt)"
## Create .emacs files
[[ -e $myhome/.emacs ]] && mv $myhome/.emacs $myhome/.emacs_orig_$install_time

cp /$localhome/user_regular/dotemacs-regular-users $myhome/.emacs
chown $myuser:$myuser $myhome/.emacs

[[ ! -e $myhome/.emacs_econ-ark_$build_date ]] && cp /$localhome/user_regular/dotemacs-regular-users $myhome/.emacs_econ-ark_$build_date

# Create .emacs.d directory with proper permissions -- avoids annoying startup warning msg
[[ -e $myhome/.emacs.d ]] && mv $myhome/.emacs.d $myhome/.emacs.d_$install_time 

# Don't install packages separately for each user - instead, link root to the existing install
[[ ! -e $myhome/.emacs.d ]] && mkdir $myhome/.emacs.d
chmod -Rf u+rw $myhome/.emacs.d
chown -Rf      $myuser:econ-ark $myhome/.emacs.d

[[ -e /$shared/.emacs.d/elpa ]] && [[ ! -e $myhome/.emacs.d/elpa ]] && ln -s /$shared/.emacs.d/elpa $myhome/.emacs.d/elpa

echo ';# -*- mode: emacs-lisp ;-*- ' > $myhome/.emacs_aliases
echo ';; This file is loaded after .emacs; put your customizations here' >> $myhome/.emacs_aliases

# Do emacs first-time setup
emacs -batch --eval "(setq debug-on-error t)" -l     $myhome/.emacs  

# Finished with default emacs configuration

