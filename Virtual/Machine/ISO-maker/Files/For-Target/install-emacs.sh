#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo 'usage: install-emacs.sh [username]'
    exit
fi

echo '' ; echo 'User must have sudoer privileges ...' ; echo ''
sudoer=false
sudo -v &> /dev/null && echo '... sudo privileges are available.' && sudoer=true
[[ "$sudoer" == "false" ]] && echo 'Exiting because no valid sudoer privileges.' && exit

myuser=$1
# Install emacs before the gui because it crashes when run in batch mode on gtk

[[ -e /var/local/status/verbose ]] && set -x && set -v

## Needs gpg for security to connect and download packages
[[ -z "$(which gpg)" ]] && sudo apt -y install gpg gnutls-bin

## Create .emacs files
sudo rm -f /home/$myuser/.emacs /root/.emacs
    
localhome=var/local/root/home
# ## Merge dotemacs conent for both root and regular users with content for regular
# cat /$localhome/user_only_for_root/dotemacs_root_and_regular_users /$localhome/user_only_for_regular/dotemacs_regular_users_only > /$localhome/$myuser/dotemacs_root_and_regular_users

[[ ! -e /home/$myuser/.emacs ]] && sudo cp /$localhome/user_regular/dotemacs-regular-users /home/$myuser/.emacs
[[ ! -e         /root/.emacs ]] && sudo cp /$localhome/user_root/dotemacs-root-user        /root/.emacs

# # Make it clear in /var/local/root/home, where its content is used
# [[ ! -e /$localhome/$myuser/dotemacs_root_and_regular_users ]]            && sudo ln -s /home/$myuser/.emacs /$localhome/$myuser/dotemacs_root_and_regular_users
# [[ ! -e /$localhome/user_only_for_root/dotemacs-root ]] && sudo ln -s /root/.emacs         /$localhome/user_only_for_root/dotemacs-root

# Permissions 
sudo chown "root:root" /root/.emacs           
chown "$myuser:$myuser" /home/$myuser/.emacs # no sudo
chmod a+rx /home/$myuser/.emacs              

# Create .emacs.d directory with proper permissions -- avoids annoying startup warning msg

[[ ! -e /home/$myuser/.emacs.d ]] && sudo mkdir /home/$myuser/.emacs.d && chown "$myuser:$myuser" /home/$myuser/.emacs.d
[[ -e /root/.emacs.d ]] && sudo rm -Rf /root/.emacs.d

sudo -i -u $myuser mkdir -p /home/$myuser/.emacs.d/elpa/gnupg
sudo chown $myuser:$myuser /home/$myuser/.emacs
sudo chown $myuser:$myuser -Rf /home/$myuser/.emacs.d
chmod a+rw /home/$myuser/.emacs.d 

echo 'keyserver hkps://keyserver.ubuntu.com:443' > /home/$myuser/.emacs.d/elpa/gnupg/gpg.conf
sudo -i -u  $myuser gpg --list-keys 
sudo -i -u  $myuser gpg --homedir /home/$myuser/.emacs.d/elpa/gnupg --list-keys
sudo -i -u  $myuser gpg --homedir /home/$myuser/.emacs.d/elpa/gnupg --receive-keys 066DAFCB81E42C40

# Do emacs first-time setup (including downloading packages)
sudo -i -u  $myuser emacs -batch -l     /home/$myuser/.emacs  

# Don't install the packages twice - instead, link root to the existing install
[[ -e /root/.emacs.d ]] && sudo rm -Rf /root/.emacs.d
ln -s /home/$myuser/.emacs.d /root/.emacs.d

# As of 20220628 there is a problem with a default certificate; comment out that certificate:
sudo apt -y install ca-certificates 
sudo sed -i 's|mozilla/DST_Root_CA_X3.crt|!mozilla/DST_Root_CA_X3.crt|g' /etc/ca-certificates.conf

# Do emacs first-time setup (including downloading packages)
sudo -i -u  $myuser emacs -batch --eval "(setq debug-on-error t)" -l     /home/$myuser/.emacs  

#sudo apt -y purge gnome-session-bin 
# Finished with emacs
