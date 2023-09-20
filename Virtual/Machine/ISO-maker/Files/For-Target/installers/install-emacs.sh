#!/bin/bash
# Installs emacs for root user and creates systemwide resources

emacs_in_env="$(env | grep -i emacs)"
echo "$emacs_in_env"

[[ "$emacs_in_env" != "" ]] && echo 'Script must be run from terminal, not from inside emacs' && exit

sudo apt -y reinstall emacs # Might have already been installed; update if so

echo '' ; echo 'User must have sudoer privileges ...' ; echo ''
sudoer=false
sudo -v &> /dev/null && echo '... sudo privileges are available.' && sudoer=true
[[ "$sudoer" == "false" ]] && echo 'Exiting because no valid sudoer privileges.' && exit

# Prepare for emacs install
[[ "$XDG_CURRENT_DESKTOP" != "" ]] && sudo apt -y install xsel xclip # Allow interchange of clipboard with system
  
[[ -e /var/local/status/verbose ]] && set -x && set -v

## Needs gpg for security to connect and download packages
[[ -z "$(which gpg)" ]] && sudo apt -y install gpg gnutls-bin

shared=/usr/local/share/emacs
user_root=user/root

install_time="$(date +%Y%m%d%H%M)"
# Create .emacs stuff
## Preserve any existing prior config for root user
## (Allows nondestructive running for user who already had configured emacs)
shared_root=$shared/$user_root
[[ -e /root/.emacs   ]] && mv /root/.emacs         /root/.emacs_orig_$install_time
[[ -e /root/.emacs.d ]] && mv /root/.emacs.d       /root/.emacs.d_orig_$install_time

localhome=var/local/sys_root_dir/home

# copy so user can change it; make link so user knows origin
cp    /$localhome/user_root/dotemacs-root-user /root/.emacs
ln -s /$localhome/user_root/dotemacs-root-user /root/.emacs_econ-ark-tools_githash_$(</var/local/About_This_Install/short.git-hash)

# Set up gpg security before emacs itself
# avoids error messages

sudo gpg -vv --keyserver hkps://keyserver.ubuntu.com --list-keys
if [[ "$?" != 0 ]]; then
    echo 'Error in setting up GPG keys; retry using\n    /var/local/installers/install-emacs.sh\n' >> /var/local/About_This_Install/XUBUNTARK_body.md
else
    sudo gpg -vv --keyserver hkps://keyserver.ubuntu.com --receive-keys 066DAFCB81E42C40
    sudo ln -s /root/.gnupg $shared/.gnupg
fi

# finally ready to install it (or reinstall if it's already installed)
sudo apt -y reinstall emacs 
 
# As of 20220628 there is a problem with a default certificate; comment out that certificate:
sudo apt -y install ca-certificates 
sudo sed -i 's|mozilla/DST_Root_CA_X3.crt|!mozilla/DST_Root_CA_X3.crt|g' /etc/ca-certificates.conf

# Do emacs first-time setup (including downloading packages)
emacs -batch --eval "(setq debug-on-error t)" -l     /root/.emacs
sudo chmod a+r /root/.emacs

# make .emacs.d directory accessible to all users, so anybody can add packages
mkdir -p $shared/.emacs.d
[[ ! -e $shared/.emacs.d/elpa ]] && sudo mv /root/.emacs.d/elpa $shared/.emacs.d/elpa
[[ ! -e /root/.emacs.d/elpa ]] && ln -s $shared/.emacs.d/elpa /root/.emacs.d/elpa
sudo chmod -Rf a+rwx $shared/.emacs.d

# Finished with emacs
