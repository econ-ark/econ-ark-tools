#!/bin/bash
# Autostart terminal upon autologin so ~/.bash_alias will be executed automatically
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
export DEBCONF_DEBUG=.*
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

myuser="econ-ark"
mypass="kra-noce"

# branch_name="$(git symbolic-ref HEAD 2>/dev/null)"
# branch_name="${branch_name#refs/heads/}"

branch_name=master
online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/"$branch_name"/Virtual/Machine/ISO-maker/Files/For-Target"

# sudo apt-get --assume-yes install refind

# Enable error reports 
# apt -y install rpl
# rpl "        'problem_types': ['Bug', 'Package']," "#       'problem_types': ['Bug', 'Package']," /etc/apport/crashdb.conf

update-grub

# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.*  sudo refind-install --yes

# Broadcom modems are common and require firmware-b43-installer for some reason
sudo apt-get -y install firmware-b43-installer

# Get some basic immediately useful tools 
sudo apt-get -y install bash-completion curl git net-tools network-manager openssh-server expect

# Install emacs before the gui because it crashes when run in batch mode on gtk

sudo apt -y install gpg # Set up security for emacs package downloading 

# Create a public key for security purposes
if [[ ! -e /home/$myuser/.ssh ]]; then
    sudo mkdir -p /home/$myuser/.ssh
    sudo chown $myuser:$myuser /home/$myuser/.ssh
    sudo chmod 700 /home/$myuser/.ssh
    sudo -u $myuser ssh-keygen -t rsa -b 4096 -q -N "" -C $myuser@XUBUNTU -f /home/$myuser/.ssh/id_rsa
fi    

# Install emacs
sudo apt -y install emacs

# 
sudo wget -O  /var/local/dotemacs                                          $online/dotemacs

[[ -e /home/econ-ark/.emacs ]] && sudo rm -f /home/econ-ark/.emacs
[[ -e          /root/.emacs ]] && sudo rm -f           root/.emacs 

sudo ln -s /var/local/dotemacs /home/econ-ark/.emacs
sudo ln -s /var/local/dotemacs /root/.emacs

# Document, in /var/local, where its content is used
sudo ln -s /home/econ-ark/.emacs /var/local/dotemacs-home 
sudo ln -s /root/.emacs          /var/local/dotemacs-root

sudo chown "root:root" /root/.emacs
sudo chmod a+rwx /home/$myuser/.emacs
sudo chown "$myuser:$myuser" /home/$myuser/.emacs

# Create .emacs.d directory with proper permissions -- avoids annoying startup warning msg

[[ ! -e /home/$myuser/.emacs.d ]] && sudo mkdir /home/$myuser/.emacs.d && sudo chown "$myuser:$myuser" /home/$myuser/.emacs.d
[[ -e /root/.emacs.d ]] && rm -Rf /root/.emacs.d

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

# Don't install the packages twice
[[ -e /root/.emacs.d ]] && sudo rm -Rf /root/.emacs.d
sudo ln -s /home/$myuser/.emacs.d /root/.emacs.d
						   
# Allow user to control networking 
sudo adduser  econ-ark netdev

# Set up automatic login
sudo -u $myuser mkdir -p   /home/$myuser/.config/autostart
sudo chown $myuser:$myuser /home/$myuser/.config/autostart

# Allow autologin (as far as unix is concerned)
sudo groupadd --system autologin
sudo adduser  econ-ark autologin
sudo gpasswd -a econ-ark autologin

# Needed for PAM autologin
sudo groupadd --system nopasswdlogin
sudo adduser  econ-ark nopasswdlogin
sudo gpasswd -a econ-ark nopasswdlogin

wget -O  /var/local/bash_aliases-add $online/bash_aliases-add

# add stuff to always execute for interactive login (if not there already)
if ! grep -q econ-ark /home/econ-ark/.bash_aliases &>/dev/null; then # Econ-ARK additions are not there yet
    sudo echo "# econ-ark additions to bash_aliases start here" >> /home/econ-ark/.bash_aliases
    sudo cat /var/local/bash_aliases-add >> /home/econ-ark/.bash_aliases
    sudo chmod a+x /home/econ-ark/.bash_aliases
    sudo chown econ-ark:econ-ark /home/econ-ark/.bash_aliases
    sudo cat /var/local/bash_aliases-add >> /root/.bash_aliases
    sudo chmod a+x /root/.bash_aliases
fi

sudo echo /usr/sbin/lightdm > /etc/X11/default-display-manager 

# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
[[ "$(which lshw)" ]] && vbox="$(lshw | grep VirtualBox) | grep VirtualBox"  && [[ "$vbox" != "" ]] && sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 && sudo adduser econ-ark vboxsf


sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt-get -qy install xubuntu-desktop^  # The caret gets a slimmed down version

sudo echo "set shared/default-x-display-manager lightdm" | DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* debconf-communicate 

sudo apt-get -y purge ubuntu-gnome-desktop
sudo apt-get -y purge gnome-shell
sudo apt-get -y purge --auto-remove ubuntu-gnome-desktop
sudo apt-get -y purge gdm3     # Get rid of gnome 
sudo apt-get -y purge numlockx
sudo apt-get -y autoremove

# # Tell it to use lightdm without asking the user 
sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt -y install lightdm 
sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt -y install xfce4
sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* dpkg-reconfigure lightdm

if ! grep -q econ-ark /etc/pam.d/lightdm-autologin; then # We have not yet added the line that makes PAM permit autologin
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/lightdm-autologin
fi

if ! grep -q econ-ark /etc/pam.d/lightdm-autologin; then # We have not yet added the line that makes PAM permit autologin
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/lightdm-greeter
fi

wget -O  /var/local/Econ-ARK.VolumeIcon.icns           $online/Disk/Icons/Econ-ARK.VolumeIcon.icns

sudo wget -O  /var/local/Econ-ARK-Logo-1536x768.jpg    $online/Econ-ARK-Logo-1536x768.jpg
cp       /var/local/Econ-ARK-Logo-1536x768.jpg    /usr/share/xfce4/backdrops

#wget -O  /var/local/Econ-ARK-Logo-1536x768.png    $online/Econ-ARK-Logo-1536x768.png

# Absurdly difficult to change the default wallpaper no matter what kind of machine you have installed to
# So just replace the default image with the one we want 
sudo rm -f                                                       /usr/share/xfce4/backdrops/xubuntu-wallpaper.png

sudo ln -s /usr/share/xfce4/backdrops/Econ-ARK-Logo-1536x768.jpg /usr/share/xfce4/backdrops/xubuntu-wallpaper.png 

# Document, in /var/local, where its content is used
sudo ln -s /usr/share/xfce4/backdrops/xubuntu-wallpaper.png      /var/local/Econ-ARK-Logo-1536x768-target.jpg

# Move but preserve the original versions
#sudo mv       /usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf  /usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf-orig
sudo mv       /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf              /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf-orig
[[ -e /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf ]] && sudo mv       /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf               /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf-orig   # Do not start ubuntu at all

# Make room for the local source
sudo mkdir -p /var/local/root/usr/share/lightdm/lightdm.conf.d/
sudo mkdir -p /var/local/root/etc/lightdm.conf.d
sudo mkdir -p /var/local/root/home/econ-ark

# Put in both /var/local and in target 
#sudo wget -O  /var/local/root/usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf $online/root/usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf
#sudo wget -O                 /usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf $online/root/usr/share/lightdm/lightdm.conf.d/60-lightdm-gtk-greeter.conf
sudo wget -O  /var/local/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf             $online/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf
sudo wget -O                 /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf             $online/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf

sudo wget -O  /var/local/root/etc/lightdm/lightdm-gtk-greeter.conf                         $online/root/etc/lightdm/lightdm-gtk-greeter.conf
sudo wget -O                 /etc/lightdm/lightdm-gtk-greeter.conf                         $online/root/etc/lightdm/lightdm-gtk-greeter.conf

# sudo rm /etc/lightdm/lightdm.conf.d/lightdm-gtk-greeter.conf

# sudo wget -O  /var/local/root/home/econ-ark/.dmrc                                          $online/root/home/econ-ark/.dmrc                               # session-name xubuntu
# sudo wget -O                 /home/econ-ark/.dmrc                                          $online/root/home/econ-ark/.dmrc                               # session-name xubuntu

sudo wget -O  /var/local/root/home/econ-ark/.xscreensaver                                  $online/xscreensaver
sudo wget -O                 /home/econ-ark/.xscreensaver                                  $online/xscreensaver

sudo chown $myuser:$myuser /home/econ-ark/.dmrc
sudo wget -O  /home/econ-ark/.xscreensaver                                   $online/xscreensaver
sudo chown $myuser:$myuser /home/econ-ark/.xscreensaver                      # session-name xubuntu

# Confusing to have this in two places; leave the one in /etc/lightdm
#[[ -e /usr/share/lightdm/lightdm-gtk-greeter.conf.d ]] && sudo rm -Rf /usr/share/lightdm/lightdm-gtk-greeter.conf.d

# Don't create ubuntu session
[[ -e /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf ]] && sudo rm -f /usr/share/lightdm/lightdm-gtk-greeter.conf.d/50-ubuntu.conf

sudo echo /usr/sbin/lightdm > /etc/X11/default-display-manager  # just to be sure 

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

# # Allow the start script to launch the GUI even though it is not a "console" user
# echo allowed_users=anybody >> /etc/X11/Xwrapper.config

# Anacron massively delays the first boot; this disbles it
# reenabled at end of finish.sh
sudo touch /etc/cron.hourly/jobs.deny       
sudo chmod a+rw /etc/cron.hourly/jobs.deny
sudo echo 0anacron > /etc/cron.hourly/jobs.deny  # Reversed in rc.local 

