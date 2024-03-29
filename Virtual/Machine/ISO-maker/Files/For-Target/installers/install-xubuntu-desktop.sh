#!/bin/bash

echo '' ; echo 'User must have sudoer privileges ...' ; echo ''
sudoer=false
sudo -v &> /dev/null && echo '... and sudo privileges are available.' && sudoer=true
[[ "$sudoer" == "false" ]] && echo 'Exiting because no valid sudoer privileges.' && exit

[[ -e /var/local/status/verbose ]] && set -x && set -v 
build_date="$(</var/local/status/build_date.txt)"

# Preconfigure lightdm
sudo apt -y install debconf debconf-utils
echo "set shared/default-x-display-manager lightdm"            | sudo debconf-communicate
echo "get shared/default-x-display-manager        "            | sudo debconf-communicate
echo "debconf debconf/priority select critical"                | sudo debconf-set-selections -v 
echo "lightdm shared/default-x-display-manager select lightdm" | sudo debconf-set-selections -v 
echo "gdm3 shared/default-x-display-manager select lightdm"    | sudo debconf-set-selections -v

# Prevent installer from stopping to ask which dm (lightdm or gdk3)
DEBCONF_PRIORITY=critical DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 sudo apt -y install lightdm lightdm-gtk-greeter
DEBCONF_PRIORITY=CRITICAL DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=5 sudo apt -y install --no-install-recommends xubuntu-desktop xfce4-goodies

# Enforce that lightdm is window manager
echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager

sudo apt -y install xubuntu-core^

backdrops=usr/share/xfce4/backdrops
backgrounds=usr/share/backgrounds/xfce

sudo mkdir -p  /$backdrops /$backgrounds
sudo chmod a+w /$backdrops /$backgrounds

sudo mv                /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf_$build_date
cp      /var/local/sys_root_dir/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf

## Do not start ubuntu at all
if [[ -e    /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf ]] && [[ -s /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf ]]; then
    sudo mv /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf_$build_date
fi

## Power manager or screensaver can shut down the machine during install
sudo apt -y --autoremove purge xfce4-power-manager # Bug in power manager causes system to become unresponsive to mouse clicks and keyboard after a few mins
sudo apt -y --autoremove purge xfce4-screensaver # Bug in screensaver causes system to become unresponsive to mouse clicks and keyboard after a few mins

