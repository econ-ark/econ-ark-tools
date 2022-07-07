#!/bin/bash

echo '' ; echo 'User must have sudoer privileges ...' ; echo ''
sudoer=false
sudo -v &> /dev/null && echo '... and sudo privileges are available.' && sudoer=true
[[ "$sudoer" == "false" ]] && echo 'Exiting because no valid sudoer privileges.' && exit

[[ -e /var/local/status/verbose ]] && set -x && set -v 
build_date="$(</var/local/build_date.txt)"
# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 sudo apt -y install --no-install-recommends linux-sound-base
# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 sudo apt -y install --no-install-recommends printer-driver-pnm2ppa
# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 sudo apt -y install --no-install-recommends ssl-cert
# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 sudo apt -y install --no-install-recommends alsa-base
# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 sudo apt -y install --no-install-recommends xrdp
# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 sudo apt -y --no-install-recommends install xubuntu-desktop
# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 sudo apt -y --no-install-recommends install xrdp 


if [[ "$(which lshw)" ]] && vbox="$(lshw 2>/dev/null | grep VirtualBox)"  && [[ "$vbox" != "" ]] ; then
    echo 'Running in VirtualBox ; econ-ark.seed should have already installed xubuntu-desktop'
    #    sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 && sudo adduser $myuser vboxsf
fi

# Removing all traces of gdm3 helps prevent the question of
# whether to use lightdm or gdm3
## Purge all packages that depend on gdm3
sudo apt -y purge gnome-shell
sudo apt -y purge gnome-settings-daemon
sudo apt -y purge at-spi2-core
sudo apt -y purge libgdm1
sudo apt -y purge gnome-session-bin
sudo apt -y purge lightdm
sudo apt -y autoremove

# Print everything that requires gdm3
sudo /var/local/check-dependencies.sh gdm3

# Preconfigure lightdm
apt -y install debconf debconf-utils
echo "set shared/default-x-display-manager lightdm" | debconf-communicate
echo "get shared/default-x-display-manager        " | debconf-communicate
echo "debconf debconf/priority select critical" |sudo debconf-set-selections -v 
echo "lightdm shared/default-x-display-manager select lightdm" |sudo debconf-set-selections -v 
echo "gdm3 shared/default-x-display-manager select lightdm" |sudo debconf-set-selections -v

export DEBCONF_PRIORITY=critical

DEBCONF_PRIORITY=critical DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 sudo apt -y install lightdm lightdm-gtk-greeter
DEBCONF_PRIORITY=CRITICAL DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 sudo apt -y install xubuntu-desktop xfce4-goodies

# Verify that lightdm is window manager

echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager

backdrops=usr/share/xfce4/backdrops

if [[ -L "/$backdrops/xubuntu-wallpaper.png"  ]]; then # original config
    sudo mv /$backdrops/xubuntu-wallpaper.png         "/$backdrops/xubuntu-wallpaper.png_$build_date"
#    sudo cp  /var/local/root/$backdrops/Econ-ARK-Logo-1536x768.png /$backdrops/xubuntu-wallpaper.png 
    sudo cp  /var/local/root/$backdrops/Econ-ARK-Logo-1536x768.*   /$backdrops
fi

# Document, in /var/local, where its content is used
## Move but preserve the original

sudo mv                /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf_$build_date
cp      /var/local/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf

## Do not start ubuntu at all
if [[ -e    /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf ]] && [[ -s /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf ]]; then
    sudo mv /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf_$build_date
fi

sudo apt -y --autoremove purge xfce4-power-manager # Bug in power manager causes system to become unresponsive to mouse clicks and keyboard after a few mins
sudo apt -y --autoremove purge xfce4-screensaver # Bug in screensaver causes system to become unresponsive to mouse clicks and keyboard after a few mins

#echo "set shared/default-x-display-manager lightdm" | debconf-communicate
# Absurdly difficult to change the default wallpaper no matter what kind of machine you have installed to
# So just replace the default image with the one we want 

# # Desktop backdrop 
# sudo cp            /var/local/Econ-ARK-Logo-1536x768.jpg    /$backdrops
