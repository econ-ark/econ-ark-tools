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

[[ -e /var/local/verbose ]] && set -x && set -v

sudo apt -y install emacs

# Needs gpg for security to connect and download packages
[[ -z "$(which gpg)" ]] && sudo apt -y install gpg gnutls-bin

[[ -e /home/$myuser/.emacs ]] && sudo rm -f /home/$myuser/.emacs
[[ -e         /root/.emacs ]] && sudo rm -f         /root/.emacs

cat /var/local/dotemacs_root_and_regular_users /var/local/dotemacs_regular_users_only > /var/local/dotemacs

[[ ! -e /home/$myuser/.emacs ]] && sudo ln -s /var/local/dotemacs /home/$myuser/.emacs
[[ ! -e          root/.emacs ]] && sudo ln -s /var/local/dotemacs_root_and_regular_users /root/.emacs

# Make it clear in /var/local, where its content is used
[[ ! -e /var/local/dotemacs-home ]] && sudo ln -s /home/$myuser/.emacs /var/local/dotemacs-home
[[ ! -e /var/local/dotemacs-root ]] && sudo ln -s /root/.emacs         /var/local/dotemacs-root

# Permissions 
sudo chown "root:root" /root/.emacs           
chmod a+rx /home/$myuser/.emacs              # no sudo to prevent root 
chown "$myuser:$myuser" /home/$myuser/.emacs  # no sudo

# Create .emacs.d directory with proper permissions -- avoids annoying startup warning msg

[[ ! -e /home/$myuser/.emacs.d ]] && sudo mkdir /home/$myuser/.emacs.d && chown "$myuser:$myuser" /home/$myuser/.emacs.d
[[ -e /root/.emacs.d ]] && sudo rm -Rf /root/.emacs.d

sudo -i -u $myuser mkdir -p /home/$myuser/.emacs.d/elpa/gnupg
sudo chown $myuser:$myuser /home/$myuser/.emacs
sudo chown $myuser:$myuser -Rf /home/$myuser/.emacs.d
chmod a+rw /home/$myuser/.emacs.d 

echo 'keyserver hkp://keys.gnupg.net' > /home/$myuser/.emacs.d/elpa/gnupg/gpg.conf
sudo -i -u  $myuser gpg --list-keys 
sudo -i -u  $myuser gpg --homedir /home/$myuser/.emacs.d/elpa/gnupg --list-keys
sudo -i -u  $myuser gpg --homedir /home/$myuser/.emacs.d/elpa/gnupg --receive-keys 066DAFCB81E42C40

# Do emacs first-time setup (including downloading packages)
sudo -i -u  $myuser emacs -batch -l     /home/$myuser/.emacs  

# Don't install the packages twice - instead, link root to the existing install
[[ -e /root/.emacs.d ]] && sudo rm -Rf /root/.emacs.d
ln -s /home/$myuser/.emacs.d /root/.emacs.d

emacs -batch -l     /home/econ-ark/.emacs  # Run in batch mode to setup everything

#sudo apt -y purge gnome-session-bin 
# Finished with emacs
