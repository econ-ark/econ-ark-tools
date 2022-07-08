#!/bin/bash
# This gets run by late_command during creation of the VM
# It installs the xubuntu-desktop server and other core tools

# To redo the whole installation sequence (without having to redownload anything):
# sudo bash -c '(rm -f /var/local/status/finished-software-install.flag ; rm -f /var/local/status/boot_first.flag ; rm -f /var/local/status/boot_second.flag ; rm -f /home/econ-ark/.gui_user_login_first.flag; rm -f /home/econ-ark/.gui_user_login_second.flag)' >/dev/null

# Presence of 'verbose' triggers bash debugging mode
[[ -e /var/local/status/verbose ]] && sudo apt -y install emacs && set -x && set -v

# Record date and time at which install script is running
# Used to mark date of original versions of files replaced
build_date="$(date +%Y%m%d)"
echo "$build_date" > /var/local/status/build_date.txt

# Remove /var/local/status/finished-software-install.flag to reinstall stuff installed here
[[ -e /var/local/status/finished-software-install.flag ]] && rm -f /var/local/status/finished-software-install.flag
# To redo the whole installation sequence (without having to redownload anything):
# sudo bash -c '(rm -f /var/local/status/finished-software-install.flag ; rm -f /var/local/status/boot_first.flag ; rm -f /var/local/status/boot_second.flag ; rm -f /home/econ-ark/.gui_user_login_first.flag; rm -f /home/econ-ark/.gui_user_login_second.flag)' >/dev/null

# Resources
myuser="econ-ark"  # Don't sudo because it needs to be an environment variable
mypass="kra-noce"  # Don't sudo because it needs to be an environment variable

# Suspend hibernation (so that a swapfile instead of partition can be used)
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Get some basic immediately useful tools 
sudo apt-get -y install bash-completion curl

# Users with appropriate groups
/var/local/config/add-users.sh |& tee /var/local/status/add-users.log

# Use correct git branches during debugging 
[[ -e /var/local/status/git_branch ]] && branch_name="$(</var/local/status/git_branch)"
# online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/"$branch_name"/Virtual/Machine/ISO-maker/Files/For-Target"

# Now install own stuff
cd /var/local

sudo bash -c '/var/local/installers/install-xubuntu-desktop.sh |& tee /var/local/status/install-xubuntu-desktop.log'

# /etc/rc.local is run by root at every boot
# it is empty by default
# Our version sequences the rest of the installation 
[[ ! -e /etc/rc.local ]] && touch /etc/rc.local 
mv /etc/rc.local /etc/rc.local_orig 
cp /var/local/root/etc/rc.local /etc/rc.local

# .bash_aliases contains the stuff that is executed at the first and second boots of gui users
if ! grep -q $myuser /home/$myuser/.bash_aliases &>/dev/null; then # Econ-ARK additions are not there yet
    sudo ln -s /var/local/root/home/user_regular/bash_aliases /home/$myuser/.bash_aliases # add them
    sudo chmod a+x /home/$myuser/.bash_aliases # ensure correct permissions
    sudo chown $myuser:$myuser /home/$myuser/.bash_aliases # ensure correct ownership
fi

if ! grep -q root /root/.bash_aliases &>/dev/null; then # Econ-ARK additions are not there yet
    # Same bash shell for root user
    sudo ln -s /var/local/root/home/user_root/bash_aliases /root/.bash_aliases 
    sudo chmod a+x /root/.bash_aliases
fi

# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
if [[ "$(which lshw)" ]] && vbox="$(lshw 2>/dev/null | grep VirtualBox)"  && [[ "$vbox" != "" ]] ; then
    sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 xserver-xorg-video-dummy
    sudo adduser $myuser vboxsf
fi

# Allow autologin for linux and for lightdm
# sudo /var/local/config/allow-autologin.sh $myuser
# Create autologin group (as far as unix is concerned)
## This may (as here) need to be after install of xubuntu-desktop (or maybe not)
sudo groupadd --system autologin
sudo adduser  $myuser autologin
sudo gpasswd -a $myuser autologin

## Allow autologin for PAM security system
sudo groupadd --system nopasswdlogin
sudo adduser  $myuser nopasswdlogin
sudo gpasswd -a $myuser nopasswdlogin


# Eliminate useless but confusing error message
# https://kb.vander.host/operating-systems/couldnt-open-etc-securetty-no-such-file-or-directory
sudo cp /usr/share/doc-util/linux-examples/securetty /etc/securetty

# Allow autologin
if ! grep -q $myuser /etc/pam.d/lightdm-autologin; then # We have not yet added the line that makes PAM permit autologin
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin' /etc/pam.d/lightdm-autologin
fi

# Not sure this is necessary
if ! grep -q $myuser /etc/pam.d/lightdm          ; then
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin # Added by Econ-ARK ' /etc/pam.d/lightdm-greeter
fi

# Make place to store/record stuff that will be installed
sudo mkdir -p /var/local/root/etc/lightdm.conf.d
sudo mkdir -p /etc/lightdm/lightdm.conf.d
sudo mkdir -p /var/local/root/home/$myuser

build_date="$(</var/local/build_date.txt)"
# Store original lightdm.conf, and substitute ours
[[ -e /usr/share/lightdm/lightdm.conf ]] && mv /usr/share/lightdm/lightdm.conf /usr/share/lightdm/lightdm.conf_$build_date
[[ -e /etc/lightdm/lightdm.conf ]]       && mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf_$build_date
sudo         cp  /var/local/root/etc/lightdm/lightdm-gtk-greeter.conf    /etc/lightdm/lightdm-gtk-greeter.conf

# Create directory designating things to autostart 
sudo -u $myuser mkdir -p   /home/$myuser/.config/autostart
chown $myuser:$myuser /home/$myuser/.config/autostart

## Autostart a terminal
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
# "scraping" means that you're not allowing vnc client to spawn new x sessions

## Execute as user to create files with correct ownership/permissions

# Installation of package needs to be done here
# (permissions require password in subscripts)
sudo apt -y install tigervnc-scraping-server
sudo /var/local/installers/install-tigervnc-scraping-server.sh $myuser

# Anacron massively delays the first boot; this disbles it
sudo touch /etc/cron.hourly/jobs.deny       
sudo chmod a+rw /etc/cron.hourly/jobs.deny
sudo echo 0anacron > /etc/cron.hourly/jobs.deny  # Reversed at end of rc.local 

# Include installer 
# sudo mkdir /tmp/iso ; sudo mount -t iso9660 /dev/sr0 /tmp/iso

# if [[ "$installer" != "" ]]; then
#     dd if="$installer" of=/var/local/XUBARK.iso
# fi

#sudo apt -y remove at-spi2-core      # Accessibility tools cause lightdm greeter error; remove
# Crashes often occur when installing grub, but have no subsequent consequence
sudo rm -f /var/crash/grub-pc.0.crash

# enable connection by ssh
sudo apt -y install openssh-server
sudo -u econ-ark touch /var/local/status/install-ssh.log # make it readable 
sudo /var/local/installers/install-ssh.sh $myuser |& tee -a /var/local/status/install-ssh.log

# When run by late_command, the machine will reboot after finishing start.sh
# rc.local will then notice that 'finish.sh' has not been run, and will run it
