#!/bin/bash
# Autostart terminal upon autologin so that ~/.bash_alias will be executed automatically
# Mostly to set up xubuntu-desktop, xfce4, and lightdm
# and to give required permissions for using these to econ-ark

set -x
set -v

# sudo apt-get --assume-yes install refind

update-grub

# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.*  sudo refind-install --yes

# sudo grub-install --efi-directory=/boot/efi


sudo apt -y install software-properties-common # Google it -- manage software

# Broadcom modems are common and require firmware-b43-installer
sudo apt-get -y install firmware-b43-installer 

online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/VirtualBox/ISO-maker/Files/For-Target"

apt -y install xubuntu-desktop^
apt -y install xfce4

# Tell it to use lightdm without asking the user 
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt -y install lightdm 
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate 

wget -O  /var/local/Econ-ARK-Logo-1536x768.jpg    $online/Econ-ARK-Logo-1536x768.jpg
wget -O  /var/local/Econ-ARK-Logo-1536x768.png    $online/Econ-ARK-Logo-1536x768.png
cp       /var/local/Econ-ARK-Logo-1536x768.jpg    /usr/share/xfce4/backdrops
cp       /var/local/Econ-ARK-Logo-1536x768.png    /usr/share/xfce4/backdrops
# Absurdly difficult to change the default wallpaper no matter what kind of machine you have installed to
# So just replace the default image with the one we want 
rm -f                                                       /usr/share/xfce4/backdrops/xubuntu-wallpaper.png 
ln -s /usr/share/xfce4/backdrops/Econ-ARK-Logo-1536x768.jpg /usr/share/xfce4/backdrops/xubuntu-wallpaper.png 
mkdir -p /usr/share/lightdm/lightdm.conf.d

xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path  --set /usr/share/xfce4/backdrops/Econ-ARK-Logo-1536x768.jpg
xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-style --set 4 # Scaling
# Set background to black 
xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/rgba1 --type double --set 0.0 --type double --set 0.0 --type double --set 0.0 --type double --set 1.0

xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual1/workspace0/image-path  --set /usr/share/xfce4/backdrops/Econ-ARK-Logo-1536x768.jpg
xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual1/workspace0/image-style --set 4
xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitorVirtual1/workspace0/rgba1 --type double --set 0.0 --type double --set 0.0 --type double --set 0.0 --type double --set 1.0

wget -O  /usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf  $online/root/usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf
wget -O  /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf              $online/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf
wget -O  /home/econ-ark/.dmrc                                           $online/root/home/econ-ark/.dmrc
[[ -e /etc/lightdm/lightdm-gtk-greeter.conf ]] && sudo rm -f /etc/lightdm/lightdm-gtk-greeter.conf

myuser=econ-ark
sudo -u $myuser mkdir -p   /home/$myuser/.config/autostart
sudo chown $myuser:$myuser /home/$myuser/.config/autostart


sudo groupadd --system autologin
sudo adduser  econ-ark autologin
sudo gpasswd -a econ-ark autologin

# Needed for PAM
sudo groupadd --system nopasswdlogin
sudo adduser  econ-ark nopasswdlogin
sudo gpasswd -a econ-ark nopasswdlogin

sudo echo /usr/sbin/lightdm > /etc/X11/default-display-manager 

cat <<EOF > /home/$myuser/.config/autostart/xfce4-terminal.desktop
[Desktop Entry]
Encoding=UTF-8
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

# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
[[ "$(which lshw)" ]] && vbox="$(lshw | grep VirtualBox) | grep VirtualBox"  && [[ "$vbox" != "" ]] && sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 && sudo adduser econ-ark vboxsf


# Anacron massively delays the first boot; this disbles it
sudo touch /etc/cron.hourly/jobs.deny
sudo chmod a+rw /etc/cron.hourly/jobs.deny
echo 0anacron > /etc/cron.hourly/jobs.deny 

