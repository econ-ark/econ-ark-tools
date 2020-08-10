#!/bin/bash
# Autostart terminal upon autologin so that ~/.bash_alias will be executed automatically

set -x
set -v

online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target"

apt -y install xubuntu-desktop^
apt -y install xfce4

# Tell it to use lightdm without asking the user 
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt -y install lightdm 
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate 

myuser=econ-ark
sudo -u $myuser mkdir -p   /home/$myuser/.config/autostart
sudo chown $myuser:$myuser /home/$myuser/.config/autostart

sudo groupadd -r autologin -a econ-ark

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
Categories=X-XFCE;X-Xfce-Toplevel;
StartupNotify=false
Terminal=false
Hidden=false
EOF

sudo chown $myuser:$myuser /home/$myuser/.config/autostart/xfce4-terminal.desktop

# Allow the start script to launch the GUI even though it is not a "console" user
echo allowed_users=anybody >> /etc/X11/Xwrapper.config

wget -O  /var/local/bash_aliases-add $online/bash_aliases-add
cat /var/local/bash_aliases-add >> /home/econ-ark/.bash_aliases

chmod a+x /home/econ-ark/.bash_aliases

sudo groupadd -r autologin
sudo gpasswd -a econ-ark autologin

sudo -u econ-ark startxfce4 &

sleep 120

sudo -u econ-ark xfconf-query -c xfce4-panel -p / -R -r

sudo -u econ-ark xfce4-panel -r

