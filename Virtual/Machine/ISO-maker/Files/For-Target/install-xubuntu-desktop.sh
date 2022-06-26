#!/bin/bash

echo '' ; echo 'User must have sudoer privileges ...' ; echo ''
sudoer=false
sudo -v &> /dev/null && echo '... and sudo privileges are available.' && sudoer=true
[[ "$sudoer" == "false" ]] && echo 'Exiting because no valid sudoer privileges.' && exit

build_date="$(</var/local/build_date.txt)"
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 apt -y install --no-install-recommends linux-sound-base
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 apt -y install --no-install-recommends printer-driver-pnm2ppa
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 apt -y install --no-install-recommends ssl-cert
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 apt -y install --no-install-recommends alsa-base
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 apt -y install --no-install-recommends xrdp
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 apt -y install --no-install-recommends xubuntu-core   # Get required but not recommended stuff
apt -y install xfce4-goodies xorg x11-xserver-utils xrdp xfce4-settings

backdrops=usr/share/xfce4/backdrops

if [[ ! -L "/$backdrops/xubuntu-wallpaper.png"  ]]; then # original config
    sudo mv /$backdrops/xubuntu-wallpaper.png         "/$backdrops/xubuntu-wallpaper.png_$build_date"
    sudo cp  /var/local/root/$backdrops/Econ-ARK-Logo-1536x768.png /$backdrops/xubuntu-wallpaper.png 
fi

# Document, in /var/local, where its content is used
## Move but preserve the original

sudo mv                /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf_$build_date
ln -s   /var/local/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf

## Do not start ubuntu at all
if [[ -e /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf ]] && [[ -s /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf ]]; then
    sudo mv     /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf_$build_date
    touch /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
fi

sudo apt -y remove xfce4-power-manager # Bug in power manager causes system to become unresponsive to mouse clicks and keyboard after a few mins
sudo apt -y remove xfce4-screensaver # Bug in screensaver causes system to become unresponsive to mouse clicks and keyboard after a few mins

#echo "set shared/default-x-display-manager lightdm" | debconf-communicate
# Absurdly difficult to change the default wallpaper no matter what kind of machine you have installed to
# So just replace the default image with the one we want 

# # Desktop backdrop 
# sudo cp            /var/local/Econ-ARK-Logo-1536x768.jpg    /$backdrops
