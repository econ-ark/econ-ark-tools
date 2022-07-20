#!/bin/bash

myuser=$1

# Create autologin group (as far as unix is concerned)
## This may (as here) need to be after install of xubuntu-desktop (or maybe not)
sudo groupadd --system autologin
sudo adduser  $myuser autologin
sudo gpasswd -a $myuser autologin

## Allow autologin for PAM security system
sudo groupadd --system nopasswdlogin
sudo adduser  $myuser nopasswdlogin
sudo gpasswd -a $myuser nopasswdlogin


# Eliminate useless but confusing error message
# https://kb.vander.host/operating-systems/couldnt-open-etc-securetty-no-such-file-or-directory
sudo cp /usr/share/doc-util/linux-examples/securetty /etc/securetty

# Allow autologin
if ! grep -q $myuser /etc/pam.d/lightdm-autologin; then # We have not yet added the line that makes PAM permit autologin
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/lightdm-autologin
fi

# Not sure this is necessary
if ! grep -q $myuser /etc/pam.d/lightdm          ; then
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin # Added by Econ-ARK ' /etc/pam.d/lightdm-greeter
fi


