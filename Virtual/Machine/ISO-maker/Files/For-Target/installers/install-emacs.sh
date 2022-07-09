#!/bin/bash
# Installs emacs for root user and creates systemwide resources

echo '' ; echo 'User must have sudoer privileges ...' ; echo ''
sudoer=false
sudo -v &> /dev/null && echo '... sudo privileges are available.' && sudoer=true
[[ "$sudoer" == "false" ]] && echo 'Exiting because no valid sudoer privileges.' && exit

# Install emacs before the gui because it crashes when run in batch mode on gtk

[[ -e /var/local/status/verbose ]] && set -x && set -v

## Needs gpg for security to connect and download packages
[[ -z "$(which gpg)" ]] && sudo apt -y install gpg gnutls-bin

# Create .emacs stuff
## Preserve any existing original config
[[ -e /root/.emacs   ]] && mv /root/.emacs   /root/.emacs_orig
[[ -e /root/.emacs.d ]] && mv /root/.emacs.d /root/.emacs.d_orig

localhome=var/local/root/home
sudo cp /$localhome/user_root/dotemacs-root-user        /root/.emacs

# Create .emacs.d directory with proper permissions -- avoids annoying startup warning msg
chmod a+rwx /root/.emacs.d 

# Set up gpg security
mkdir -p /root/.emacs.d/elpa/gnupg

echo 'keyserver hkps://keyserver.ubuntu.com:443' > /root/.emacs.d/elpa/gnupg/gpg.conf
sudo gpg --list-keys 
sudo gpg --homedir /home/$myuser/.emacs.d/elpa/gnupg --list-keys
sudo gpg --homedir /home/$myuser/.emacs.d/elpa/gnupg --receive-keys 066DAFCB81E42C40

# Do emacs first-time setup (including downloading packages)
emacs -batch -l     /home/$myuser/.emacs  

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
