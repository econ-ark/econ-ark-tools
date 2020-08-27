#!/bin/bash
# This gets run by rc.local the first time the VM boots
# It installs the xubuntu-desktop server and other core tools
# The reboot at the end kicks off the running of the finish.sh script
# The GUI launches automatically at the first boot after installation of the desktop

rm /var/local/finished-software-install
# To redo the whole installation sequence (without having to redownload anything):
# sudo bash -c '(rm -f /var/local/finished-software-install ; rm -f /var/log/firstboot.log ; rm -f /var/log/secondboot.log ; rm -f /home/econ-ark/.firstboot ; rm -f /home/econ-ark/.secondboot)' >/dev/null

# define convenient "download" function
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

# Debugging 
set -x ; set -v 

# # These probably are not needed given that they are also provided before the relevant commands below
# # Left here because no time to debug and see if they can be deleted
# sudo export DEBCONF_DEBUG=.*
# sudo export DEBIAN_FRONTEND=noninteractive
# sudo export DEBCONF_NONINTERACTIVE_SEEN=true

# Resources
myuser="econ-ark"  # Don't sudo because it needs to be an environment variable
mypass="kra-noce"  # Don't sudo because it needs to be an environment variable

# This allows git branches during debugging 
branch_name=master 
online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/"$branch_name"/Virtual/Machine/ISO-maker/Files/For-Target"
                       
# Configure boot information
sudo update-grub

# Broadcom modems are common and require firmware-b43-installer for some reason
sudo apt-get -y install firmware-b43-installer

# Get some basic immediately useful tools 
sudo apt-get -y install bash-completion curl git net-tools network-manager openssh-server expect

# Create a public key for security purposes
if [[ ! -e /home/$myuser/.ssh ]]; then
    mkdir -p /home/$myuser/.ssh
    chown $myuser:$myuser /home/$myuser/.ssh
    chmod 700 /home/$myuser/.ssh
    sudo -u $myuser ssh-keygen -t rsa -b 4096 -q -N "" -C $myuser@XUBUNTU -f /home/$myuser/.ssh/id_rsa
fi    

sudo apt -y install gpg # Required to set up security for emacs package downloading 

# Install emacs before the gui because it crashes when run in batch mode on gtk

sudo apt -y install emacs

sudo wget -O  /var/local/dotemacs                                          $online/dotemacs

[[ -e /home/econ-ark/.emacs ]] && sudo rm -f /home/econ-ark/.emacs
[[ -e          /root/.emacs ]] && sudo rm -f           root/.emacs 

# Link both of them to the downloaded template 
sudo ln -s /var/local/dotemacs /home/econ-ark/.emacs
sudo ln -s /var/local/dotemacs /root/.emacs

# Make it clear in /var/local, where its content is used
sudo ln -s /home/econ-ark/.emacs /var/local/dotemacs-home 
sudo ln -s /root/.emacs          /var/local/dotemacs-root

# Permissions 
chown "root:root" /root/.emacs                # no sudo
chmod a+rwx /home/$myuser/.emacs              # no sudo
chown "$myuser:$myuser" /home/$myuser/.emacs  # no sudo

# Create .emacs.d directory with proper permissions -- avoids annoying startup warning msg

[[ ! -e /home/$myuser/.emacs.d ]] && sudo mkdir /home/$myuser/.emacs.d && chown "$myuser:$myuser" /home/$myuser/.emacs.d
[[ -e /root/.emacs.d ]] && sudo rm -Rf /root/.emacs.d

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

# Do emacs first-time setup (including downloading packages)
sudo -i -u  econ-ark emacs -batch -l     /home/econ-ark/.emacs  

# Don't install the packages twice - instead, link root to the existing install
[[ -e /root/.emacs.d ]] && sudo rm -Rf /root/.emacs.d
ln -s /home/$myuser/.emacs.d /root/.emacs.d

# Finished with emacs


# Allow user to control networking 
sudo adduser econ-ark netdev

# .bash_aliases is run by all interactive scripts
wget -O  /var/local/bash_aliases-add $online/bash_aliases-add

# add this stuff to any existing ~/.bash_aliases
if ! grep -q econ-ark /home/econ-ark/.bash_aliases &>/dev/null; then # Econ-ARK additions are not there yet
    sudo echo "# econ-ark additions to bash_aliases start here" >> /home/econ-ark/.bash_aliases
    sudo cat /var/local/bash_aliases-add >> /home/econ-ark/.bash_aliases
    sudo chmod a+x /home/econ-ark/.bash_aliases
    sudo chown econ-ark:econ-ark /home/econ-ark/.bash_aliases
    sudo cat /var/local/bash_aliases-add >> /root/.bash_aliases
    sudo chmod a+x /root/.bash_aliases
fi

# One of several ways to try to make sure lightdm is the display manager
sudo echo /usr/sbin/lightdm > /etc/X11/default-display-manager 

# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
[[ "$(which lshw)" ]] && vbox="$(lshw | grep VirtualBox) | grep VirtualBox"  && [[ "$vbox" != "" ]] && sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 && sudo adduser econ-ark vboxsf

# Install xubuntu-desktop 
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt-get -qy install xubuntu-desktop^  # The caret gets a slimmed down version # no sudo 

# Another way to try to make sure lightdm is the display manager
echo "set shared/default-x-display-manager lightdm" | DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* debconf-communicate  # no sudo 

# Yet another -- delete the alternatives 
sudo apt-get -y purge ubuntu-gnome-desktop
sudo apt-get -y purge gnome-shell
sudo apt-get -y purge --auto-remove ubuntu-gnome-desktop
sudo apt-get -y purge gdm3     # Get rid of gnome 
sudo apt-get -y purge numlockx
sudo apt-get -y autoremove

# Once again -- doubtless only one of the methods is needed, but debugging which would take too long
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt -y install lightdm     # no sudo
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt -y install xfce4       # no sudo
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* dpkg-reconfigure lightdm   # no sudo

# Allow autologin (as far as unix is concerned)
sudo groupadd --system autologin
sudo adduser  econ-ark autologin
sudo gpasswd -a econ-ark autologin

# Group for autologin for PAM 
sudo groupadd --system nopasswdlogin
sudo adduser  econ-ark nopasswdlogin
sudo gpasswd -a econ-ark nopasswdlogin

# Allow autologin
if ! grep -q econ-ark /etc/pam.d/lightdm-autologin; then # We have not yet added the line that makes PAM permit autologin
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/lightdm-autologin
fi

# Not sure this is necessary
if ! grep -q econ-ark /etc/pam.d/lightdm          ; then # We have not yet added the line that makes PAM permit autologin
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin # Added by Econ-ARK ' /etc/pam.d/lightdm-greeter
fi

# # Autologin to the keyring too
# # wiki.archlinux.org/index.php/GNOME/Keyring
# if ! grep -q gnome /etc/pam.d/login           ; then # automatically log into the keyring too
#     sudo sed -i '1 a\
# auth    optional      pam_gnome_keyring.so # Added by Econ-ARK ' /etc/pam.d/login
# fi

# if ! grep -q gnome /etc/pam.d/login           ; then # automatically log into the keyring too
#     sudo sed -i '1 a\
# auth    optional      pam_gnome_keyring.so # Added by Econ-ARK ' /etc/pam.d/login
# fi

# if ! grep -q gnome /etc/pam.d/common-session           ; then # automatically log into the keyring too
#     sudo sed -i '1 a\
# session optional pam_gnome_keyring.so autostart # Added by Econ-ARK ' /etc/pam.d/common-session
# fi

# if ! grep -q gnome /etc/pam.d/passwd           ; then # automatically log into the keyring too
#     sudo sed -i '1 a\
# password optional pam_gnome_keyring.so # Added by Econ-ARK ' /etc/pam.d/passwd
# fi

# # Start the keyring on boot
# echo 'eval $(/usr/bin/gnome-keyring-daemon --start --components=pks11,secrets,ssh) ; export SSH_AUTH_SOCK' >> /home/econ-ark/.xinitrc 

# echo '[[ -n "$DESKTOP_SESSION" ]] && eval $(gnome-keyring-daemon --start) && export SSH_AUTH_SOCK' >> /home/econ-ark/.bash_profile

# For some reason the pattern for the url this image doesn't fit the pattern of other downloads
wget -O  /var/local/Econ-ARK.VolumeIcon.icns           https://github.com/econ-ark/econ-ark-tools/raw/master/Virtual/Machine/ISO-maker/Disk/Icons/Econ-ARK.VolumeIcon.icns

# Desktop backdrop 
wget -O  /var/local/Econ-ARK-Logo-1536x768.jpg    $online/Econ-ARK-Logo-1536x768.jpg
cp            /var/local/Econ-ARK-Logo-1536x768.jpg    /usr/share/xfce4/backdrops

# Absurdly difficult to change the default wallpaper no matter what kind of machine you have installed to
# So just replace the default image with the one we want 
sudo rm -f                                                       /usr/share/xfce4/backdrops/xubuntu-wallpaper.png

sudo ln -s /usr/share/xfce4/backdrops/Econ-ARK-Logo-1536x768.jpg /usr/share/xfce4/backdrops/xubuntu-wallpaper.png 

# Document, in /var/local, where its content is used
sudo ln -s /usr/share/xfce4/backdrops/xubuntu-wallpaper.png      /var/local/Econ-ARK-Logo-1536x768-target.jpg

# Move but preserve the original versions
sudo mv       /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf              /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf-orig
# Do not start ubuntu at all
[[ -e /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf ]] && sudo mv       /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf               /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf-orig   

# Make home for the local source
sudo mkdir -p /var/local/root/usr/share/lightdm/lightdm.conf.d/
sudo mkdir -p /var/local/root/etc/lightdm.conf.d
sudo mkdir -p /var/local/root/home/econ-ark

# Put in both /var/local and in target 
wget -O  /var/local/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf             $online/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf
wget -O                 /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf             $online/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf

wget -O  /var/local/root/etc/lightdm/lightdm-gtk-greeter.conf                         $online/root/etc/lightdm/lightdm-gtk-greeter.conf
wget -O                 /etc/lightdm/lightdm-gtk-greeter.conf                         $online/root/etc/lightdm/lightdm-gtk-greeter.conf

# One of many ways to try to prevent screen lock
wget -O  /var/local/root/home/econ-ark/.xscreensaver                                  $online/xscreensaver
wget -O                 /home/econ-ark/.xscreensaver                                  $online/xscreensaver

chown $myuser:$myuser /home/econ-ark/.dmrc
wget -O  /home/econ-ark/.xscreensaver                                   $online/xscreensaver
chown $myuser:$myuser /home/econ-ark/.xscreensaver                      # session-name xubuntu

# Create directory designating things to autostart 
sudo -u $myuser mkdir -p   /home/$myuser/.config/autostart
chown $myuser:$myuser /home/$myuser/.config/autostart

# Autostart a terminal
cat <<EOF > /home/$myuser/.config/autostart/xfce4-terminal.desktop
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=xfce4-terminal
Comment=Terminal
Exec=xfce4-terminal --geometry 80x24-0-0
OnlyShowIn=XFCE;
Categories=X-XFCE;X-Xfce-Toplevel;
StartupNotify=false
Terminal=false
Hidden=false
EOF

chown $myuser:$myuser /home/$myuser/.config/autostart/xfce4-terminal.desktop

# Anacron massively delays the first boot; this disbles it
sudo touch /etc/cron.hourly/jobs.deny       
sudo chmod a+rw /etc/cron.hourly/jobs.deny
sudo echo 0anacron > /etc/cron.hourly/jobs.deny  # Reversed at end of rc.local 

