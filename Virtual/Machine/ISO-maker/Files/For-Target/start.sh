#!/bin/bash
# This gets run by late_command during creation of the VM
# It installs the xubuntu-desktop server and other core tools
# The reboot at the end kicks off the running of the finish.sh script
# The GUI is available after the
#    service lightdm start
# command completes

# To redo the whole installation sequence (without having to redownload anything):
# sudo bash -c '(rm -f /var/local/finished-software-install ; rm -f /var/log/firstboot.log ; rm -f /var/log/secondboot.log ; rm -f /home/econ-ark/.firstboot ; rm -f /home/econ-ark/.secondboot)' >/dev/null


# # Export stdout and stderr to a log file;
# # should be invoked after turning off buffering: set stdbuf -i0 -o0 -e0 /var/local/start.sh
# cd /var/local
# # stdbuf -i0 -o0 -e0 exec   > >(tee -ia start.log)
# # stdbuf -i0 -o0 -e0 exec  2> >(tee -ia start.log >&2)
# # exec 19> start.log
# # export BASH_XTRACEFD="19"

# set -x
# set -v

# echo 'before bad command'
# junk .

# echo 'before good command'
# ls | head -1
# exit

# Presence of 'verbose' triggers bash debugging mode
[[ -e /var/local/verbose ]] && set -x && set -v 

# Record date and time at which install script is running
# Used to mark date of original versions of files replaced
build_date="$(date +%Y%m%d%H%S)"
echo "$build_date" > /var/local/build_date.txt

# Remove /var/local/finished-software-install to reinstall stuff installed here
[[ -e /var/local/finished-software-install ]] && rm -f /var/local/finished-software-install
# To redo the whole installation sequence (without having to redownload anything):
# sudo bash -c '(rm -f /var/local/finished-software-install ; rm -f /var/log/firstboot.log ; rm -f /var/log/secondboot.log ; rm -f /home/econ-ark/.firstboot ; rm -f /home/econ-ark/.secondboot)' >/dev/null

# Resources
myuser="econ-ark"  # Don't sudo because it needs to be an environment variable
mypass="kra-noce"  # Don't sudo because it needs to be an environment variable

# Suspend hibernation (so that a swapfile instead of partition can be used)
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Get some basic immediately useful tools 
sudo apt-get -y install bash-completion net-tools network-manager curl

# # # # Use Debian Installer in noninteractive mode to prevent questions 
export DEBCONF_DEBUG='.*'
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# # Install lightdm, xubuntu, and friends
# # DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* apt-get -y install lightdm
# apt -y remove gdm3
# apt -y purge gdm3
# echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
# DEBCONF_FRONTEND=noninteractive apt -y install lightdm
# Create econ-ark and econ-ark-xrdp users
/var/local/add-users.sh

# Use correct git branches during debugging 
[[ -e /var/local/git_branch ]] && branch_name="$(</var/local/git_branch)"
online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/"$branch_name"/Virtual/Machine/ISO-maker/Files/For-Target"

# Now install own stuff
cd /var/local

# GitHub command line tools
./install-gh-cli-tools.sh

# Removing all traces of gdm3 helps prevent the question of
# whether to use lightdm or gdm3

## apt -y install --no-install-recommends xfce4-terminal 

/var/local/install-xubuntu-desktop.sh |& tee /var/local/install-xubuntu-desktop.log

# Includes the whisker menu
sudo apt -y install xfce4-goodies 

# Prepare for emacs install
sudo apt -y install xsel xclip # Allow interchange of clipboard with system
sudo apt -y install gpg gnutls-bin # Required to set up security for emacs package downloading

./install-emacs.sh $myuser

# add this stuff to any existing ~/.bash_aliases
if ! grep -q $myuser /home/$myuser/.bash_aliases &>/dev/null; then # Econ-ARK additions are not there yet
    sudo cat /var/local/bash_aliases-add >> /home/$myuser/.bash_aliases # add them
    sudo chmod a+x /home/$myuser/.bash_aliases # ensure correct permissions
    sudo chown $myuser:$myuser /home/$myuser/.bash_aliases # ensure correct ownership
    # Same bash shell for root user
    sudo cat /var/local/bash_aliases-add >> /root/.bash_aliases 
    sudo chmod a+x /root/.bash_aliases
fi

# # # Purge unneeded stuff
# # sudo apt-get -y purge ubuntu-gnome-desktop
# # sudo apt-get -y purge gnome-shell
# # sudo apt-get -y purge --auto-remove ubuntu-gnome-desktop
# # sudo apt-get -y purge gdm3     # Get rid of gnome 
# # sudo apt-get -y purge numlockx
# # sudo apt-get -y autoremove

# # If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
# if [[ "$(which lshw)" ]] && vbox="$(lshw 2>/dev/null | grep VirtualBox)"  && [[ "$vbox" != "" ]] ; then
#     sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 && sudo adduser $myuser vboxsf
# fi

# Create autologin group (as far as unix is concerned)
## This may (as here) need to be after install of xubuntu-desktop (or maybe not)
sudo groupadd --system autologin
sudo adduser  $myuser autologin
sudo gpasswd -a $myuser autologin

## Allow autologin for PAM security system
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
    sudo cp /etc/pam.d/lightdm-greeter /etc/pam.d/lightdm-greeter_$commit_date
    sudo sed -i '1 a\
auth    sufficient      pam_succeed_if.so user ingroup nopasswdlogin # Added by Econ-ARK ' /etc/pam.d/lightdm-greeter
fi

# Make place to store/record stuff that will be installed
#sudo mkdir -p /var/local/root/usr/share/lightdm/lightdm.conf.d/
sudo mkdir -p /var/local/root/etc/lightdm.conf.d
sudo mkdir -p /etc/lightdm/lightdm.conf.d
sudo mkdir -p /var/local/root/home/$myuser

build_date="$(</var/local/build_date.txt)"
# Store original lightdm.conf, and substitute ours
# [[ -e /usr/share/lightdm/lightdm.conf ]] && mv /usr/share/lightdm/lightdm.conf /usr/share/lightdm/lightdm.conf_$build_date
# sudo                            cp    /var/local/root/etc/lightdm/lightdm.conf /usr/share/lightdm/lightdm.conf

[[ -e /usr/share/lightdm/lightdm.conf ]] && mv /usr/share/lightdm/lightdm.conf /usr/share/lightdm/lightdm.conf_$build_date
[[ -e /etc/lightdm/lightdm.conf ]]       && mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf_$build_date
sudo         cp  /var/local/root/etc/lightdm/lightdm.conf                /etc/lightdm/lightdm.conf
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
sudo apt -y install tigervnc-scraping-server

## Execute as user to create files with correct ownership/permissions
sudo -u $myuser /var/local/setup-tigervnc-scraping-server.sh

# Anacron massively delays the first boot; this disbles it
sudo touch /etc/cron.hourly/jobs.deny       
sudo chmod a+rw /etc/cron.hourly/jobs.deny
sudo echo 0anacron > /etc/cron.hourly/jobs.deny  # Reversed at end of rc.local 

# sudo mkdir /tmp/iso ; sudo mount -t iso9660 /dev/sr0 /tmp/iso

# if [[ "$installer" != "" ]]; then
#     dd if="$installer" of=/var/local/XUBARK.iso
# fi

#sudo apt -y remove at-spi2-core      # Accessibility tools cause lightdm greeter error; remove 
sudo rm -f /var/crash/grub-pc.0.crash

# When run by late_command, the machine will reboot after finishing start.sh
