#!/bin/bash
# This gets run by rc.local the first time the VM boots
# It installs the xubuntu-desktop server and other core tools
# The reboot at the end kicks off the running of the finish.sh script
# The GUI launches automatically at the first boot after installation of the desktop

[[ -e /var/local/finished-software-install ]] && rm -f /var/local/finished-software-install
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


# Resources
myuser="econ-ark"  # Don't sudo because it needs to be an environment variable
mypass="kra-noce"  # Don't sudo because it needs to be an environment variable

# # stackoverflow.com/questions check-whether-a-user-exists
# if ! id "ubuntu" &>/dev/null; then # Probably created by seed
#     sudo adduser --disabled-password --gecos "" "ubuntu"
# else # Probably created by multipass
#     sudo adduser --disabled-password --gecos "" "$myuser"
# fi

# sudo chpasswd <<<"$myuser:$mypass"

# sudo usermod -aG sudo $myuser
# sudo usermod -aG cdrom $myuser
# sudo usermod -aG adm $myuser
# sudo usermod -aG plugdev $myuser

# Suspend hibernation (so that a swapfile instead of partition can be used)
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
# Debugging 
set -x ; set -v 

export DEBCONF_DEBUG=.*
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# Install lightdm, xubuntu, and friends
sudo apt -y install lightdm xfce4 xubuntu-desktop^  # The caret gets a slimmed down version
sudo apt -y install xfce4-goodies xorg x11-server-utils xrdp

# Install gh github command line tools 
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt -y install gh

# sudo apt -y install tasksel
# sudo tasksel install standard
# Make links in /var/local to files installed in other places
# (to provide a transparent gude to all the places the system has been tweaked)

if [ -e /usr/bin/xfce4-about ]; then # xfce/xubuntu is installed
    # blueman generates distracting and useless error messages
    sudo apt -y remove blueman
    # Do the stuff necessary for configuring x
    
    # On some systems, xfce4-power-manager causes a crash if you don't quit it before reboot 
#    xfce4powermanagerexists="$(xfconf-query --channel xfce4-power-manager --list &>/dev/null)"
#    xfce4powermanagerexistsCode="$?"
#    [[ "xfce4powermanagerexistsCode" == "0" ]] && xfce4-power-manager --quit

    # Permit xwindows
#    [[ -e /home/$myuser/.Xauthority ]] && rm -f /home/$myuser/.Xauthority
#    [[ -e          /root/.Xauthority ]] && rm -f          /root/.Xauthority

#    # Create new empty file
#    touch /home/$myuser/.Xauthority

    # DATE="$(stat -c %z /proc)"
    # size="MAX"
    # [[ -e /var/local/Size-To-Make-Is-MIN ]] && size="MIN"
    # hostdate="xubark-$(printf %s `date -d"$DATE" +%Y%m%d%H%M`)"
    # sudo hostname "$hostdate"
    # sudo echo "$hostdate" > /etc/hostname
#    /var/local/Xauthority-generate.sh "$hostdate" "$myuser"
    
    #    sudo tasksel xubuntu-desktop
#    apt -y install xfce4-goodies
fi    

cd /var/local
mkdir -p root/etc/default
# mkdir -p root/.config/rclone
#mkdir -p root/etc/systemd/system/getty@tty1.service.d  # /override.conf Allows autologin to console as econ-ark
#mkdir -p root/usr/share/lightdm/lightdm.conf.d         # Configure display manager 

[[ -e root/etc/sshd_config ]] && sudo cp root/etc/sshd_config /etc/sshd_config
# These items are created in econ-ark.seed; put them in /var/local so all system mods are findable there
# The ! -e are there in case the script is being rerun after a first install
#[[ ! -e /var/local/rc.local                                     ]] && ln -s /etc/rc.local                                          /var/local/root/etc
#[[ ! -e /var/local/root/etc/default    			        ]] && ln -s /etc/default/grub                                      /var/local/root/etc/default    
#[[ ! -e /var/local/root/etc/systemd/system/getty@tty1.service.d ]] && ln -s /etc/systemd/system/getty@tty1.service.d/override.conf /var/local/root/etc/systemd/system/getty@tty1.service.d
# /usr/share/lightdm/lightdm.conf.d is standard location for lightdm config; if /var/local doesn't have it, use default
#[[ ! -e /var/local/root/usr/share/lightdm                       ]] && ln -s /usr/share/lightdm/lightdm.conf.d                      /var/local/root/usr/share/lightdm                      

sudo -u $myuser sudo /var/local/setup-tigervnc-scraping-server.sh


# If x0vncserver not running 
pgrep x0vncserver >/dev/null
# "$?" -eq 1 implies that no such process exists, in which case it should be started
if [[ $? -eq 1 ]]; then
    sudo -u $myuser xfce4-terminal --display :0 --minimize --execute x0vncserver -geometry 1024x768 -display :0.0 -PasswordFile=/home/$myuser/.vnc/passwd &> /dev/null &
    sleep 2
    sudo -u $myuser xfce4-terminal --display :0 --execute tail --follow /var/local/start-and-finish.log &
fi

# already done: # sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 xfce4-goodies
# sudo DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg reconfigure lightdm
cd /var/local

msg="$(cat ./About_This_Install/commit-msg.txt)"
short_hash="$(cat ./About_This_Install/short.git-hash)"
commit_date="$(cat ./About_This_Install/commit_date)"

# Create the "About This Install" markdown file
cat <<EOF > /var/local/About_This_Install.md
# Detailed Info About This Installation

This machine (virtual or real) was built using 

https://github.com/econ-ark/econ-ark-tools.git

using scripts in commit $short_hash 
with commit message "$msg"
on date "$commit_date"

Starting at the root of a cloned version of that repo,
you should be able to reproduce the installer with:

    git checkout $short_hash
    cd Virtual/Machine/ISO-maker ; ./create-unattended-iso_Econ-ARK-by-size.sh [ MIN | MAX ]

or, if you want to make and post both MAX and MIN ISO's to Google Drive:

    ./make-and-send-both.sh

A copy of the ISO installer that generated this machine should be in the

    /media

directory.

EOF

# This allows git branches during debugging 
[[ -e ./git_branch ]] && branch_name=$(<git_branch)
online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/"$branch_name"/Virtual/Machine/ISO-maker/Files/For-Target"

# # Get pasword-encrypted rclone key for Google drive 
# wget -O  /var/local/root/.config/rclone/rcloneconf.zip $online/root/.config/rclone/rcloneconf.zip

# Broadcom modems are common and require firmware-b43-installer for some reason
sudo apt-get -y install b43-fwcutter
sudo apt-get -y install firmware-b43-installer
sudo apt-get -y --fix-broken install

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

# Prepare for emacs install
sudo apt -y install xsel xclip # Allow interchange of clipboard with system
sudo apt -y install gpg # Required to set up security for emacs package downloading 

./install-emacs.sh $myuser

# Allow user to control networking 
sudo adduser $myuser netdev

# add this stuff to any existing ~/.bash_aliases
if ! grep -q $myuser /home/$myuser/.bash_aliases &>/dev/null; then # Econ-ARK additions are not there yet
    sudo cat /var/local/bash_aliases-add >> /home/$myuser/.bash_aliases
    sudo chmod a+x /home/$myuser/.bash_aliases
    sudo chown $myuser:$myuser /home/$myuser/.bash_aliases
    sudo cat /var/local/bash_aliases-add >> /root/.bash_aliases
    sudo chmod a+x /root/.bash_aliases
fi

# # One of several ways to try to make sure lightdm is the display manager
# sudo echo /usr/sbin/lightdm > /etc/X11/default-display-manager 

# Install xubuntu-desktop 
#DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt-get -qy install xubuntu-desktop^  # The caret gets a slimmed down version # no sudo 

# # Another way to try to make sure lightdm is the display manager
# echo "set shared/default-x-display-manager lightdm" | DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* debconf-communicate  # no sudo 

# Yet another -- delete the alternatives 
sudo apt-get -y purge ubuntu-gnome-desktop
sudo apt-get -y purge gnome-shell
sudo apt-get -y purge --auto-remove ubuntu-gnome-desktop
sudo apt-get -y purge gdm3     # Get rid of gnome 
sudo apt-get -y purge numlockx
sudo apt-get -y autoremove

# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
if [[ "$(which lshw)" ]] && vbox="$(lshw 2>/dev/null | grep VirtualBox)"  && [[ "$vbox" != "" ]] ; then
    
    sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 && sudo adduser $myuser --no-password vboxsf
    # Get a bugfix release of lightdm to avoid a crash on VM's
    # https://launchpad.net/ubuntu/+source/lightdm-gtk-greeter
    # Bug #1890394 "Lightdm-gtk-greeter coredump during boot"
    #    wget --tries=0 -O /var/local/lightdm-gtk-greeter_2.0.6-0ubuntu1_amd64.deb $online/lightdm-gtk-greeter_2.0.6-0ubuntu1_amd64.deb
    #    dpkg -i /var/local/lightdm-gtk-greeter_2.0.6-0ubuntu1_amd64.deb
    
fi


# # Once again -- doubtless only one of the methods is needed, but debugging which would take too long
# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt -y install lightdm     # no sudo
# DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt -y install xfce4       # no sudo
# # DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* dpkg-reconfigure lightdm   # no sudo

# sudo apt-get -y install x11-xserver-utils # Installs xrandr, among other utilities

# Create econ-ark and econ-ark-xrdp users
/var/local/add-users.sh

# Allow autologin (as far as unix is concerned)
sudo groupadd --system autologin
sudo adduser  $myuser autologin
sudo gpasswd -a $myuser autologin

# Group for autologin for PAM 
sudo groupadd --system nopasswdlogin
sudo adduser  $myuser nopasswdlogin
sudo gpasswd -a $myuser nopasswdlogin

# Allow autologin
if ! grep -q $myuser /etc/pam.d/lightdm-autologin; then # We have not yet added the lines that makes PAM permit autologin
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/lightdm-autologin
fi

# Not sure this is necessary
if ! grep -q $myuser /etc/pam.d/lightdm          ; then # We have not yet added the line that makes PAM permit autologin
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin # Added by Econ-ARK ' /etc/pam.d/lightdm-greeter
    #    sudo sed -i '1 a\
	#auth    include         system-login # Added by Econ-ARK ' /etc/pam.d/lightdm-greeter
fi

# Keyring autologin caused some problems that were hard to fix
# They appeared to be because further config of some kind was needed
# # Autologin to the keyring too
# # wiki.archlinux.org/index.php/GNOME/Keyring
if ! grep -q gnome /etc/pam.d/login           ; then # automatically log into the keyring too
    cp /etc/pam.d/login /etc/pam.d/login_orig
    sudo sed -i '1 a\
    auth    optional      pam_gnome_keyring.so # Added by Econ-ARK ' /etc/pam.d/login
fi

# if ! grep -q gnome /etc/pam.d/login           ; then # automatically log into the keyring too
#     sudo sed -i '1 a\
    # auth    optional      pam_gnome_keyring.so # Added by Econ-ARK ' /etc/pam.d/login
# fi

if ! grep -q gnome /etc/pam.d/common-session           ; then # automatically log into the keyring too
    cp /etc/pam.d/common-session /etc/pam.d/common-session_orig
    sudo sed -i '1 a\
    session optional pam_gnome_keyring.so autostart # Added by Econ-ARK ' /etc/pam.d/common-session
fi

if ! grep -q gnome /etc/pam.d/passwd           ; then # automatically log into the keyring too
    cp /etc/pam.d/passwd /etc/pam.d/passwd_orig
    sudo sed -i '1 a\
    password optional pam_gnome_keyring.so # Added by Econ-ARK ' /etc/pam.d/passwd
fi

# # Start the keyring on boot
echo 'eval $(/usr/bin/gnome-keyring-daemon --start --components=pks11,secrets,ssh) ; export SSH_AUTH_SOCK' >> /home/$myuser/.xinitrc ; sudo chown $myuser:$myuser /home/$myuser/.xinitrc ; sudo chmod a+x /home/$myuser/.xinitrc 

# echo '[[ -n "$DESKTOP_SESSION" ]] && eval $(gnome-keyring-daemon --start) && export SSH_AUTH_SOCK' >> /home/$myuser/.bash_profile

# For some reason the pattern for the url this image doesn't fit the pattern of other downloads
# wget -O  /var/local/Econ-ARK.VolumeIcon.icns           https://github.com/econ-ark/econ-ark-tools/raw/$branch/Virtual/Machine/ISO-maker/Disk/Icons/Econ-ARK.VolumeIcon.icns

# Desktop backdrop 
#wget -O  /var/local/Econ-ARK-Logo-1536x768.jpg    $online/Econ-ARK-Logo-1536x768.jpg
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
sudo mkdir -p /var/local/root/home/$myuser

# Put in both /var/local and in target 
# wget --tries=0 -O  /var/local/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf             $online/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf
## System default for lightdm is  /usr/share/lightdm/lightdm.conf.d/
cp /var/local/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf 
#wget --tries=0 -O                 /usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf             $online/root/usr/share/lightdm/lightdm.conf.d/60-xubuntu.conf

# -> runcmd # cp /var/local/root/etc/lightdm/lightdm.conf /usr/share/lightdm/lightdm.conf
#wget --tries=0 -O  /var/local/root/etc/lightdm/lightdm-gtk-greeter.conf                         $online/root/etc/lightdm/lightdm-gtk-greeter.conf
#wget --tries=0 -O                 /etc/lightdm/lightdm-gtk-greeter.conf                         $online/root/etc/lightdm/lightdm-gtk-greeter.conf

# One of many ways to try to prevent screen lock
#wget --tries=0 -O  /var/local/root/home/$myuser/.xscreensaver                                  $online/xscreensaver
#wget --tries=0 -O                 /home/$myuser/.xscreensaver                                  $online/xscreensaver

#?? chown $myuser:$myuser /home/$myuser/.dmrc
# wget --tries=0 -O  /home/$myuser/.xscreensaver                                   $online/xscreensaver
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

# Anacron massively delays the first boot; this disbles it
sudo touch /etc/cron.hourly/jobs.deny       
sudo chmod a+rw /etc/cron.hourly/jobs.deny
sudo echo 0anacron > /etc/cron.hourly/jobs.deny  # Reversed at end of rc.local 

# mdadm is for managing RAID systems but can cause backup problems; disable
sudo apt -y remove mdadm

sudo mkdir /tmp/iso ; sudo mount -t iso9660 /dev/sr0 /tmp/iso


# if [[ "$installer" != "" ]]; then
#     dd if="$installer" of=/var/local/XUBARK.iso
# fi


sudo apt -y remove xfce4-power-manager # Bug in power manager causes system to become unresponsive to mouse clicks and keyboard after a few mins
sudo apt -y remove xfce4-screensaver # Bug in screensaver causes system to become unresponsive to mouse clicks and keyboard after a few mins
#sudo apt -y remove at-spi2-core      # Accessibility tools cause lightdm greeter error; remove 
sudo rm -f /var/crash/grub-pc.0.crash

# sleep 3600
