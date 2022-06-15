#!/bin/bash
# This gets run by late_command during creation of the VM
# It installs the xubuntu-desktop server and other core tools
# The reboot at the end kicks off the running of the finish.sh script
# The GUI is available after the
#    service lightdm start
# command completes

# Remove /var/local/finished-software-install to reinstall stuff installed here
[[ -e /var/local/finished-software-install ]] && rm -f /var/local/finished-software-install
# To redo the whole installation sequence (without having to redownload anything):
# sudo bash -c '(rm -f /var/local/finished-software-install ; rm -f /var/log/firstboot.log ; rm -f /var/log/secondboot.log ; rm -f /home/econ-ark/.firstboot ; rm -f /home/econ-ark/.secondboot)' >/dev/null

# Resources
myuser="econ-ark"  # Don't sudo because it needs to be an environment variable
mypass="kra-noce"  # Don't sudo because it needs to be an environment variable

# Suspend hibernation (so that a swapfile instead of partition can be used)
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
# Presence of 'verbose' triggers bash debugging mode
[[ -e /var/local/verbose ]] && set -x ; set -v 

# Use Debian Installer in noninteractive mode to prevent questions 
export DEBCONF_DEBUG=.*
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Install lightdm, xubuntu, and friends
sudo apt -y install lightdm xfce4 xubuntu-desktop^  # The caret gets a slimmed down version
sudo apt -y install xfce4-goodies xorg x11-xserver-utils xrdp

# Create econ-ark and econ-ark-xrdp users
/var/local/add-users.sh

# GitHub command line tools
./install-gh-cli-tools.sh

# Populate About_This_Install directory with info specific to this run of the installer
cd /var/local

commit_msg="$(cat ./About_This_Install/commit-msg.txt)"
short_hash="$(cat ./About_This_Install/short.git-hash)"
commit_date="$(cat ./About_This_Install/commit_date)"

# Create the "About This Install" markdown file
cat <<EOF > /var/local/About_This_Install.md
# Detailed Info About This Installation

This machine (virtual or real) was built using 

https://github.com/econ-ark/econ-ark-tools.git

using scripts in commit $short_hash 
with commit message "$commit_msg"
on date "$commit_date"

Starting at the root of a cloned version of that repo,
you should be able to reproduce the installer with:

    git checkout $short_hash
    cd Virtual/Machine/ISO-maker ; ./create-unattended-iso_Econ-ARK-by-size.sh [ MIN | MAX ]

or, if you want to make and post both MAX and MIN ISO's to Google Drive:

    ./make-and-send-both.sh

A copy of the ISO installer that generated this machine should be in the

    /installers

directory.

EOF

# Use correct git branches during debugging 
[[ -e ./git_branch ]] && branch_name=$(<git_branch)
online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/"$branch_name"/Virtual/Machine/ISO-maker/Files/For-Target"

# Broadcom modems are common and require firmware-b43-installer for some reason
sudo apt-get -y install b43-fwcutter
sudo apt-get -y install firmware-b43-installer

# Get some basic immediately useful tools 
sudo apt-get -y install bash-completion net-tools network-manager openssh-server rpl gnome-disk-utility

# Packages present in "live" but not in "legacy" version of server
# https://ubuntuforums.org/showthread.php?t=2443047
sudo apt-get -y install cloud-init console-setup eatmydata gdisk libeatmydata1 

# Create a public key for security purposes
if [[ ! -e /home/$myuser/.ssh ]]; then
    mkdir -p /home/$myuser/.ssh
    chown $myuser:$myuser /home/$myuser/.ssh
    chmod 700 /home/$myuser/.ssh
    sudo -u $myuser ssh-keygen -t rsa -b 4096 -q -N "" -C $myuser@XUBUNTU -f /home/$myuser/.ssh/id_rsa
fi    

# Enable public key authentication
d /var/local
[[ -e root/etc/ssh/sshd_config ]] && sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config_$commit_date
cp root/etc/ssh/sshd_config /etc/ssh/sshd_config


# Prepare for emacs install
sudo apt -y install xsel xclip # Allow interchange of clipboard with system
sudo apt -y install gpg # Required to set up security for emacs package downloading 

./install-emacs.sh $myuser

# Allow user to control networking 
sudo adduser $myuser netdev

# add this stuff to any existing ~/.bash_aliases
if ! grep -q $myuser /home/$myuser/.bash_aliases &>/dev/null; then # Econ-ARK additions are not there yet
    sudo cat /var/local/bash_aliases-add >> /home/$myuser/.bash_aliases # add them
    sudo chmod a+x /home/$myuser/.bash_aliases # ensure correct permissions
    sudo chown $myuser:$myuser /home/$myuser/.bash_aliases # ensure correct ownership
    # Same bash shell for root user
    sudo cat /var/local/bash_aliases-add >> /root/.bash_aliases 
    sudo chmod a+x /root/.bash_aliases
fi

# Choose lightdm as display manager
sudo echo /usr/sbin/lightdm > /etc/X11/default-display-manager 

# Purge unneeded stuff
sudo apt-get -y purge ubuntu-gnome-desktop
sudo apt-get -y purge gnome-shell
sudo apt-get -y purge --auto-remove ubuntu-gnome-desktop
sudo apt-get -y purge gdm3     # Get rid of gnome 
sudo apt-get -y purge numlockx
sudo apt-get -y autoremove

# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
if [[ "$(which lshw)" ]] && vbox="$(lshw 2>/dev/null | grep VirtualBox)"  && [[ "$vbox" != "" ]] ; then
    sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 && sudo adduser $myuser --no-password vboxsf
fi

# Create autologin group (as far as unix is concerned)
sudo groupadd --system autologin
sudo adduser  $myuser autologin
sudo gpasswd -a $myuser autologin

# Allow autologin for PAM security system
sudo groupadd --system nopasswdlogin
sudo adduser  $myuser nopasswdlogin
sudo gpasswd -a $myuser nopasswdlogin

# Allow autologin
if ! grep -q $myuser /etc/pam.d/lightdm-autologin; then # We have not yet added the line that makes PAM permit autologin
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/lightdm-autologin
fi

# Not sure this is necessary
if ! grep -q $myuser /etc/pam.d/lightdm          ; then
    cp /etc/pam.d/lightdm-greeter /etc/pam.d/lightdm-greeter_$commit_date
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin # Added by Econ-ARK ' /etc/pam.d/lightdm-greeter
fi

# Autologin to the keyring too
# wiki.archlinux.org/index.php/GNOME/Keyring
if ! grep -q gnome /etc/pam.d/login           ; then # automatically log into the keyring too
    cp /etc/pam.d/login /etc/pam.d/login_$commit_date
    sudo sed -i '1 a\
    auth    optional      pam_gnome_keyring.so # Added by Econ-ARK ' /etc/pam.d/login
fi

if ! grep -q gnome /etc/pam.d/common-session           ; then 
    cp /etc/pam.d/common-session /etc/pam.d/common-session_$commit_date
    sudo sed -i '1 a\
    session optional pam_gnome_keyring.so autostart # Added by Econ-ARK ' /etc/pam.d/common-session
fi

if ! grep -q gnome /etc/pam.d/passwd           ; then # automatically log into the keyring too
    cp /etc/pam.d/passwd /etc/pam.d/passwd_$commit_date
    sudo sed -i '1 a\
    password optional pam_gnome_keyring.so # Added by Econ-ARK ' /etc/pam.d/passwd
fi

# Start the keyring on boot
if ! grep -s SSH_AUTH_SOCK /home/$myuser/.xinitrc >/dev/null; then
    echo 'eval $(/usr/bin/gnome-keyring-daemon --start --components=pks11,secrets,ssh) ; export SSH_AUTH_SOCK' >> /home/$myuser/.xinitrc ; sudo chown $myuser:$myuser /home/$myuser/.xinitrc ; sudo chmod a+x /home/$myuser/.xinitrc
    # echo '[[ -n "$DESKTOP_SESSION" ]] && eval $(gnome-keyring-daemon --start) && export SSH_AUTH_SOCK' >> /home/$myuser/.bash_profile
fi

# Desktop backdrop 
cp            /var/local/Econ-ARK-Logo-1536x768.jpg    /usr/share/xfce4/backdrops

# Absurdly difficult to change the default wallpaper no matter what kind of machine you have installed to
# So just replace the default image with the one we want 
sudo rm -f                                                       /usr/share/xfce4/backdrops/xubuntu-wallpaper.png
sudo ln -s /usr/share/xfce4/backdrops/Econ-ARK-Logo-1536x768.jpg /usr/share/xfce4/backdrops/xubuntu-wallpaper.png 

# Document, in /var/local, where its content is used
sudo ln -s /usr/share/xfce4/backdrops/xubuntu-wallpaper.png      /var/local/Econ-ARK-Logo-1536x768-target.jpg

# Move but preserve the original versions
sudo mv           /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf_$commit_date
cp /var/local/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf 
## Do not start ubuntu at all
[[ -e /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf ]] && sudo mv       /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf               /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf_$commit_date   

# Make place to store/record stuff that will be installed
sudo mkdir -p /var/local/root/usr/share/lightdm/lightdm.conf.d/
sudo mkdir -p /var/local/root/etc/lightdm.conf.d
sudo mkdir -p /var/local/root/home/$myuser

[[ -e /usr/share/lightdm/lightdm.conf ]] && cp /usr/share/lightdm/lightdm.conf /usr/share/lightdm/lightdm.conf_$commit_date
cp    /var/local/root/etc/lightdm/lightdm.conf /usr/share/lightdm/lightdm.conf

cp /var/local/xscreensaver /home/$myuser/.xscreensaver
chown $myuser:$myuser /home/$myuser/.xscreensaver                      # session-name xubuntu

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

# Allow interactive commands to be preseeded
sudo apt -y install expect

# Scraping server allows outside user to watch display X:0
# scraping server means that you're not allowing vnc client to spawn new x sessions
sudo apt -y install tigervnc-scraping-server

## Execute as user to create files with correct ownership/permissions
sudo -u $myuser /var/local/setup-tigervnc-scraping-server.sh

# Start the GUI
service lightdm start 

# If x0vncserver not running, run it
pgrep x0vncserver >/dev/null
if [[ $? -eq 1 ]]; then # no such process exists
    # start it
    sudo -u $myuser xfce4-terminal --display :0 --minimize --execute x0vncserver -display :0.0 -PasswordFile=/home/$myuser/.vnc/passwd &> /dev/null &
    sleep 2
    sudo -u $myuser xfce4-terminal --display :0 --execute tail --follow /var/local/start-and-finish.log 2>/dev/null &
fi

# Anacron massively delays the first boot; this disbles it
sudo touch /etc/cron.hourly/jobs.deny       
sudo chmod a+rw /etc/cron.hourly/jobs.deny
sudo echo 0anacron > /etc/cron.hourly/jobs.deny  # Reversed at end of rc.local 

# mdadm is for managing RAID systems but can cause backup problems; disable
sudo apt -y remove mdadm

# sudo mkdir /tmp/iso ; sudo mount -t iso9660 /dev/sr0 /tmp/iso

# if [[ "$installer" != "" ]]; then
#     dd if="$installer" of=/var/local/XUBARK.iso
# fi


sudo apt -y remove xfce4-power-manager # Bug in power manager causes system to become unresponsive to mouse clicks and keyboard after a few mins
sudo apt -y remove xfce4-screensaver # Bug in screensaver causes system to become unresponsive to mouse clicks and keyboard after a few mins
#sudo apt -y remove at-spi2-core      # Accessibility tools cause lightdm greeter error; remove 
sudo rm -f /var/crash/grub-pc.0.crash

# sleep 3600
