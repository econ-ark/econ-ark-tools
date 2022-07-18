#!/bin/bash
# This script is run by late_command during creation of the VM

# It creates the econ-ark and econ-ark-xrdp users
# and does other prep for installation of xubuntu-desktop

# To redo the whole installation sequence (without having to redownload anything):
# cd /var/local/status ; rm *.flag ; sudo /var/local/start.sh

# Presence of 'verbose' triggers bash debugging mode

[[ -e /var/local/status/verbose ]] && set -x && set -v

# Record date and time at which install script is running
# Used to mark date of original versions of any files replaced
build_date="$(date +%Y%m%d)"
build_time="$(date +%Y%m%d%H%M)"

echo "$build_date" > /var/local/status/build_date.txt
echo "$build_time" > /var/local/status/build_time.txt

# Remove /var/local/status/finished-software-install.flag to reinstall stuff installed here
[[ -e /var/local/status/finished-software-install.flag ]] && rm -f /var/local/status/finished-software-install.flag

# Resources
vncuser="econ-ark"      # Don't sudo because it needs to be an environment variable
rdpuser="econ-ark-xrdp" # Configs for xrdp and for xwindows are incompatible  
mypass="kra-noce"       # both have the same password

# Suspend hibernation (so that a swapfile instead of partition can be used)
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# Get some basic immediately useful tools 
sudo apt-get -y install bash-completion curl

# Create with appropriate groups
/var/local/config/add-users.sh |& tee /var/local/status/add-users.log

# Use correct git branches during debugging 
[[ -e /var/local/status/git_branch ]] && branch_name="$(</var/local/status/git_branch)"

# Now install xubuntu-desktop
cd /var/local

sudo bash -c '/var/local/installers/install-xubuntu-desktop.sh |& tee /var/local/status/install-xubuntu-desktop.log'

# /etc/rc.local is run by root at every boot
# it is empty by default
# Our version sequences the rest of the installation 
[[ ! -e /etc/rc.local ]] && touch /etc/rc.local 
mv /etc/rc.local /etc/rc.local_orig 
cp /var/local/sys_root_dir/etc/rc.local /etc/rc.local

# .bash_aliases contains the stuff that is executed at the first and second boots of gui users
if ! grep -q root /root/.bash_aliases &>/dev/null; then # Econ-ARK additions are not there yet
    # Allows custom .bashrc for root user
    sudo ln -s /var/local/sys_root_dir/home/user_root/bash_aliases /root/.bash_aliases 
    sudo chmod a+x /root/.bash_aliases
fi

# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
if [[ "$(which lshw)" ]] && vbox="$(lshw 2>/dev/null | grep VirtualBox)"  && [[ "$vbox" != "" ]] ; then
    sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 xserver-xorg-video-dummy
fi

# Add autostart requirements
for user in $vncuser $rdpuser; do
    if ! grep -q $user /home/$user/.bash_aliases &>/dev/null; then # Econ-ARK additions are not there yet
	sudo ln -s /var/local/sys_root_dir/home/user_regular/bash_aliases /home/$user/.bash_aliases # add them
	sudo chmod a+x /home/$user/.bash_aliases # ensure correct permissions
	sudo chown $user:$user /home/$user/.bash_aliases # ensure correct ownership
    fi

    # Create directory designating things to autostart 
    sudo -u $user mkdir -p   /home/$user/.config/autostart
    chown $user:$user /home/$user/.config/autostart

    # allow sharing files with host if running in virtualbox
    sudo adduser $user vboxsf  

    ## Autostart a terminal
    cat <<EOF > /home/$user/.config/autostart/xfce4-terminal.desktop
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

    chown $user:$user /home/$user/.config/autostart/xfce4-terminal.desktop
done

sudo /var/local/config/allow-autologin.sh $vncuser
sudo /var/local/config/allow-autologin.sh $rdpuser

# Make place to store/record stuff that will be installed
sudo mkdir -p /var/local/sys_root_dir/etc/lightdm.conf.d
sudo mkdir -p /etc/lightdm/lightdm.conf.d
sudo mkdir -p /var/local/sys_root_dir/home/$vncuser

build_date="$(</var/local/status/build_date.txt)"
# Store original lightdm.conf, and substitute ours
[[ -e /usr/share/lightdm/lightdm.conf ]] && mv /usr/share/lightdm/lightdm.conf /usr/share/lightdm/lightdm.conf_$build_date
[[ -e /etc/lightdm/lightdm.conf ]]       && mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf_$build_date
sudo         cp  /var/local/sys_root_dir/etc/lightdm/lightdm-gtk-greeter.conf    /etc/lightdm/lightdm-gtk-greeter.conf


# Allow interactive commands to be preseeded
sudo apt -y install expect

# Scraping server allows outside user to watch display X:0
# "scraping" means that you're not allowing vnc client to spawn new x sessions

## Execute as user to create files with correct ownership/permissions

# Installation of package needs to be done here
# (permissions require password in subscripts)
sudo apt -y install tigervnc-scraping-server

# Needs to be installed for a user but with sudo permissions
sudo -u $vncuser /var/local/installers/install-tigervnc-scraping-server.sh $vncuser

# Anacron massively delays the first boot; this disbles it
sudo touch /etc/cron.hourly/jobs.deny       
sudo chmod a+rw /etc/cron.hourly/jobs.deny
sudo echo 0anacron > /etc/cron.hourly/jobs.deny  # Reversed at end of rc.local 

sudo apt -y install at-spi2-core      # If not insalled lots of lightdm errmsg
# Crashes often occur when installing grub, but have no subsequent consequence
sudo rm -f /var/crash/grub-pc.0.crash

sudo /var/local/installers/install-and-configure-xrdp.sh $vncuser |& tee -a /var/local/status/install-and-configure-xrdp.log

# Tools to detect various kinds of hardware
sudo apt -y install xserver-xorg-input-libinput xserver-xorg-input-evdev xserver-xorg-input-mouse xserver-xorg-input-synaptics

# When run by late_command, the machine will reboot after finishing start.sh
# rc.local will then notice that 'finish.sh' has not been run, and will run it
