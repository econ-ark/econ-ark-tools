#!/bin/bash
# Autostart terminal upon autologin so that ~/.bash_alias will be executed automatically
# Mostly to set up xubuntu-desktop, xfce4, and lightdm
# and to give required permissions for using these to econ-ark

# define download function
# courtesy of http://fitnr.com/showing-file-download-progress-using-wget.html
download()
{
    local url=$1
    #    echo -n "    "
    wget --progress=dot $url 2>&1 | grep --line-buffered "%" | \
        sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    #    echo -ne "\b\b\b\b"
    #    echo " DONE"
}


set -x
set -v

myuser="econ-ark"
mypass="kra-noce"


online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target"

# sudo apt-get --assume-yes install refind

update-grub

# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.*  sudo refind-install --yes
# sudo grub-install --efi-directory=/boot/efi

# Broadcom modems are common and require firmware-b43-installer
sudo apt-get -y install firmware-b43-installer

# Get some basic useful tools 
sudo apt-get -y install bash-completion 

# Install emacs before the gui because it crashes when run in batch mode on gtk
# Set up security for emacs package downloading 
# Security (needed for emacs)
sudo apt -y install gpg 

# Create a public key for security purposes
if [[ ! -e /home/$myuser/.ssh ]]; then
    mkdir -p /home/$myuser/.ssh
    chown $myuser:$myuser /home/$myuser/.ssh
    chmod 700 /home/$myuser/.ssh
    sudo -u $myuser ssh-keygen -t rsa -b 4096 -q -N "" -C $myuser@XUBUNTU -f /home/$myuser/.ssh/id_rsa
fi    

# Install emacs
sudo apt -y install emacs

download "https://raw.githubusercontent.com/ccarrollATjhuecon/Methods/master/Tools/Config/tool/emacs/dot/emacs-ubuntu-virtualbox"

cp emacs-ubuntu-virtualbox /home/econ-ark/.emacs
cp emacs-ubuntu-virtualbox /root/.emacs
chown "root:root" /root/.emacs
chmod a+rwx /home/$myuser/.emacs
chown "$myuser:$myuser" /home/$myuser/.emacs

rm -f emacs-ubuntu-virtualbox
# Create .emacs.d directory with proper permissions -- avoids annoying startup warning msg

[[ ! -e /home/$myuser/.emacs.d ]] && sudo mkdir /home/$myuser/.emacs.d && sudo chown "$myuser:$myuser" /home/$myuser/.emacs.d
[[ ! -e /root/.emacs.d ]] && mkdir /root/.emacs.d

sudo -i -u econ-ark mkdir -p /home/econ-ark/.emacs.d/elpa
sudo -i -u econ-ark mkdir -p /home/econ-ark/.emacs.d/elpa/gnupg
sudo chown econ-ark:econ-ark /home/econ-ark/.emacs
sudo chown econ-ark:econ-ark -Rf /home/econ-ark/.emacs.d
chmod a+rw /home/$myuser/.emacs.d 

sudo -i -u  econ-ark gpg --list-keys 
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa       --list-keys
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa/gnupg --list-keys
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa       --receive-keys 066DAFCB81E42C40
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa/gnupg --receive-keys 066DAFCB81E42C40

sudo -i -u  econ-ark emacs -batch -l     /home/econ-ark/.emacs  # do emacs first-time setup
sudo                 emacs -batch -l              /root/.emacs  # do emacs first-time setup


apt -y install xubuntu-desktop^
apt -y install xfce4

# Tell it to use lightdm without asking the user 
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt -y install lightdm 
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* dpkg-reconfigure lightdm

wget -O  /var/local/Econ-ARK-Logo-1536x768.jpg    $online/Econ-ARK-Logo-1536x768.jpg
wget -O  /var/local/Econ-ARK-Logo-1536x768.png    $online/Econ-ARK-Logo-1536x768.png
cp       /var/local/Econ-ARK-Logo-1536x768.jpg    /usr/share/xfce4/backdrops
cp       /var/local/Econ-ARK-Logo-1536x768.png    /usr/share/xfce4/backdrops
# Absurdly difficult to change the default wallpaper no matter what kind of machine you have installed to
# So just replace the default image with the one we want 
rm -f                                                       /usr/share/xfce4/backdrops/xubuntu-wallpaper.png 
ln -s /usr/share/xfce4/backdrops/Econ-ARK-Logo-1536x768.jpg /usr/share/xfce4/backdrops/xubuntu-wallpaper.png 
mkdir -p /usr/share/lightdm/lightdm.conf.d

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
cat /var/local/bash_aliases-add >> /root/.bash_aliases
chmod a+x /root/.bash_aliases


# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
[[ "$(which lshw)" ]] && vbox="$(lshw | grep VirtualBox) | grep VirtualBox"  && [[ "$vbox" != "" ]] && sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 && sudo adduser econ-ark vboxsf


# Anacron massively delays the first boot; this disbles it
sudo touch /etc/cron.hourly/jobs.deny
sudo chmod a+rw /etc/cron.hourly/jobs.deny
echo 0anacron > /etc/cron.hourly/jobs.deny 

