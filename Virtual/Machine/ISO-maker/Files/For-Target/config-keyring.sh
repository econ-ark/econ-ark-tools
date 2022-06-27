#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo 'usage: install-emacs.sh [username]'
    exit
fi

myuser="$1"
build_date="$(</var/local/build_date.txt)"

# Autologin to the keyring too
# wiki.archlinux.org/index.php/GNOME/Keyring
if ! grep -q gnome /etc/pam.d/login           ; then # automatically log into the keyring too
    sudo cp /etc/pam.d/login /etc/pam.d/login_$build_date
    sudo sed -i '1 a\
    auth    optional      pam_gnome_keyring.so # Added by Econ-ARK ' /etc/pam.d/login
fi

if ! grep -q gnome /etc/pam.d/common-session           ; then 
    sudo cp /etc/pam.d/common-session /etc/pam.d/common-session_$build_date
    sudo sed -i '1 a\
    session optional pam_gnome_keyring.so autostart # Added by Econ-ARK ' /etc/pam.d/common-session
fi

if ! grep -q gnome /etc/pam.d/passwd           ; then # automatically log into the keyring too
    sudo cp /etc/pam.d/passwd /etc/pam.d/passwd_$build_date
    sudo sed -i '1 a\
    password optional pam_gnome_keyring.so # Added by Econ-ARK ' /etc/pam.d/passwd
fi

# Start the keyring on boot
if ! grep -s SSH_AUTH_SOCK /home/$myuser/.xinitrc >/dev/null; then
    echo 'eval $(/usr/bin/gnome-keyring-daemon --start --components=pks11,secrets,ssh) ; export SSH_AUTH_SOCK' >> /home/$myuser/.xinitrc ; sudo chown $myuser:$myuser /home/$myuser/.xinitrc ; sudo chmod a+x /home/$myuser/.xinitrc
    # echo '[[ -n "$DESKTOP_SESSION" ]] && eval $(gnome-keyring-daemon --start) && export SSH_AUTH_SOCK' >> /home/$myuser/.bash_profile
fi

