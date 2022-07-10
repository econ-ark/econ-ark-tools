
# Installs emacs for root user and creates systemwide resources

echo '' ; echo 'User must have sudoer privileges ...' ; echo ''
sudoer=false
sudo -v &> /dev/null && echo '... sudo privileges are available.' && sudoer=true
[[ "$sudoer" == "false" ]] && echo 'Exiting because no valid sudoer privileges.' && exit

# Install emacs before the gui because it crashes when run in batch mode on gtk

[[ -e /var/local/status/verbose ]] && set -x && set -v

## Needs gpg for security to connect and download packages
[[ -z "$(which gpg)" ]] && sudo apt -y install gpg gnutls-bin

shared=/usr/local/share/emacs
user_root=user/root

install_time="$(date +%Y%m%d%H%M)"
# Create .emacs stuff
## Preserve any existing original config for root user
shared_root=$shared/$user_root
[[ -e /root/.emacs   ]]        && mv /root/.emacs         /root/.emacs_orig_$install_time
# [[ -e $shared_root/.emacs.d ]] && mv $shared/.emacs.d $shared/.emacs.d_orig_$install_time

localhome=var/local/root/home

# copy so user can change it; make link so user knows origin
cp    /$localhome/user_root/dotemacs-root-user /root/.emacs
ln -s /$localhome/user_root/dotemacs-root-user /root/.emacs_econ-ark_githash_$(</var/local/About_This_Install/short.git-hash)

# Set up gpg security before emacs itself
# avoids error messages

sudo gpg -vv --auto-key-retrieve --keyserver hkps://keyserver.ubuntu.com --list-keys
sudo gpg -vv --auto-key-retrieve --keyserver hkps://keyserver.ubuntu.com --receive-keys 066DAFCB81E42C40
sudo ln -s /root/.gnupg $shared/.gnupg

# finally ready to install it
sudo apt -y install emacs 

# As of 20220628 there is a problem with a default certificate; comment out that certificate:
sudo apt -y install ca-certificates 
sudo sed -i 's|mozilla/DST_Root_CA_X3.crt|!mozilla/DST_Root_CA_X3.crt|g' /etc/ca-certificates.conf

# Do emacs first-time setup (including downloading packages)
emacs -batch --eval "(setq debug-on-error t)" -l     /root/.emacs  

# make .emacs.d directory accessible to all users, so anybody can add packages
mkdir -p $shared/.emacs.d
sudo mv /root/.emacs.d/elpa /$shared/.emacs.d/elpa
ln -s /$shared/.emacs.d/elpa /root/.emacs.d/elpa
sudo chmod -Rf a+rwx $shared/.emacs.d 

# Finished with emacs
