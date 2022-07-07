#!/bin/bash
# This gets run by late_command during creation of the VM
# It installs the xubuntu-desktop server and other core tools
# The reboot at the end kicks off the running of the finish.sh script
# The GUI is available after the
#    service lightdm start
# command completes

# To redo the whole installation sequence (without having to redownload anything):
# sudo bash -c '(rm -f /var/local/status/finished-software-install.flag ; rm -f /var/local/status/boot_first.flag ; rm -f /var/local/status/boot_second.flag ; rm -f /home/econ-ark/.gui_user_login_first.flag; rm -f /home/econ-ark/.gui_user_login_second.flag)' >/dev/null


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
[[ -e /var/local/status/verbose ]] && set -x && set -v

sudo apt -y install emacs

# Record date and time at which install script is running
# Used to mark date of original versions of files replaced
build_date="$(date +%Y%m%d%H%S)"
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
/var/local/installers/add-users.sh |& tee /var/local/status/add-users.log

# Use correct git branches during debugging 
[[ -e /var/local/status/git_branch ]] && branch_name="$(</var/local/status/git_branch)"
# online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/"$branch_name"/Virtual/Machine/ISO-maker/Files/For-Target"

# Now install own stuff
cd /var/local

sudo bash -c '/var/local/installers/install-xubuntu-desktop.sh |& tee /var/local/status/install-xubuntu-desktop.log'

# rc.local is empty by default
[[ ! -e /etc/rc.local ]] && touch /etc/rc.local 
mv /etc/rc.local /etc/rc.local_orig 
cp /var/local/root/etc/rc.local /etc/rc.local

# add this stuff to any existing ~/.bash_aliases
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

# # # Purge unneeded stuff
# # sudo apt-get -y purge ubuntu-gnome-desktop
# # sudo apt-get -y purge gnome-shell
# # sudo apt-get -y purge --auto-remove ubuntu-gnome-desktop
# # sudo apt-get -y purge gdm3     # Get rid of gnome 
# # sudo apt-get -y purge numlockx
# # sudo apt-get -y autoremove

# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
if [[ "$(which lshw)" ]] && vbox="$(lshw 2>/dev/null | grep VirtualBox)"  && [[ "$vbox" != "" ]] ; then
    sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 xserver-xorg-video-dummy && sudo adduser $myuser vboxsf
fi

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
#sudo         cp  /var/local/root/etc/lightdm/lightdm.conf                /etc/lightdm/lightdm.conf
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
sudo -u $myuser /var/local/installers/install-tigervnc-scraping-server.sh

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

/var/local/installers/install-ssh.sh $myuser

# sleep 10800 # = 60*60*3 hours
