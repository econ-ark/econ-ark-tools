#!/bin/bash
# Autostart terminal upon autologin so that ~/.bash_alias will be executed automatically

set -x
set -v

# Update everything 
sudo apt -y update

sudo apt-get -y install firmware-b43-installer

# Play nice with Macs
sudo apt -y install avahi-daemon avahi-discover avahi-utils libnss-mdns mdns-scan

# Start avahi so it can be found on local network
#avahi-daemon start

DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt -y install lightdm 
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate 

sudo apt -y install xubuntu-desktop^  # Puzzled why it's not already installed since it's in the preseed 
sudo apt -y install xfce4             # ditto

DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate 

sudo apt-get -y install xubuntu-desktop^

myuser=econ-ark
sudo -u $myuser mkdir -p   /home/$myuser/.config/autostart
sudo chown $myuser:$myuser /home/$myuser/.config/autostart

sudo echo /usr/sbin/lightdm > /etc/X11/default-display-manager 

cat <<EOF > /home/$myuser/.config/autostart/xfce4-terminal.desktop
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=xfce4-terminal
Comment=Terminal
Exec=xfce4-terminal
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=false
EOF

sudo chown $myuser:$myuser /home/$myuser/.config/autostart/xfce4-terminal.desktop

touch /home/econ-ark/.bash_aliases

online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker-Server"

refindFile="refind-install-MacOS.sh"
curl -L -o /var/local/bash_aliases-add $online/bash_aliases-add
curl -L -o /var/local/grub-menu.sh $online/grub-menu.sh 
curl -L -o /var/local/Econ-ARK.VolumeIcon.icns $online/Disk/Icons/Econ-ARK.VolumeIcon.icns
curl -L -o /var/local/Econ-ARK.disk_label      $online/Disk/Labels/Econ-ARK.disklabel    
curl -L -o /var/local/Econ-ARK.disk_label_2x   $online/Disk/Labels/Econ-ARK.disklabel_2x 
curl -L -o /var/local/$refindFile $online/$refindFile
chmod +x /var/local/$refindFile

touch /home/econ-ark/.bash_aliases

cat /var/local/bash_aliases-add >> /home/econ-ark/.bash_aliases

chmod a+x /home/econ-ark/.bash_aliases
