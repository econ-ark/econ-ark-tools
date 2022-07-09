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
[[ -e /root/.emacs   ]] && mv /root/.emacs   /root/.emacs_$(date +%Y%m%d%H%M)
[[ -e /root/.emacs.d ]] && mv /root/.emacs.d /root/.emacs.d_$(date +%Y%m%d%H%M)

localhome=var/local/root/home
sudo cp /$localhome/user_root/dotemacs-root-user        /root/.emacs
sudo chmod a+rx /root/.emacs

# Set up gpg security before emacs itself 
mkdir -p /root/.emacs.d/elpa/gnupg

echo 'keyserver hkps://keyserver.ubuntu.com:443' > /root/.emacs.d/elpa/gnupg/gpg.conf
sudo gpg --list-keys 
sudo gpg --homedir /root/.emacs.d/elpa/gnupg --list-keys
sudo gpg --homedir /root/.emacs.d/elpa/gnupg --receive-keys 066DAFCB81E42C40

# make .emacs.d directory accessible to all users, so anybody can add packages
chmod -Rf a+rwx /root/.emacs.d 

# As of 20220628 there is a problem with a default certificate; comment out that certificate:
sudo apt -y install ca-certificates 
sudo sed -i 's|mozilla/DST_Root_CA_X3.crt|!mozilla/DST_Root_CA_X3.crt|g' /etc/ca-certificates.conf

# Do emacs first-time setup (including downloading packages)
emacs -batch --eval "(setq debug-on-error t)" -l     /root/.emacs  

# Finished with emacs
