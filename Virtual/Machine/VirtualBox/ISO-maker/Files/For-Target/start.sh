#!/bin/bash
# Autostart terminal upon autologin so that ~/.bash_alias will be executed automatically

set -x
set -v

online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target"

curl -L -o /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf  $online/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf
apt -y install xubuntu-desktop^
apt -y install xfce4

# Set econ-ark user to autologin
curl -L -o /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf  $online/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf

# Tell it to use lightdm without asking the user 
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt -y install lightdm 
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate 

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
Categories=X-XFCE;X-Xfce-Toplevel;
StartupNotify=false
Terminal=false
Hidden=false
EOF

sudo chown $myuser:$myuser /home/$myuser/.config/autostart/xfce4-terminal.desktop

curl -L -o /var/local/bash_aliases-add $online/bash_aliases-add
cat /var/local/bash_aliases-add >> /home/econ-ark/.bash_aliases

chmod a+x /home/econ-ark/.bash_aliases

startxfce4 & 

xfconf-query -c xfce4-panel -p / -R -r

xfce4-panel -r

