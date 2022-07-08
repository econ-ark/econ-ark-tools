#!/bin/bash
# start.sh installs GUI then reboots;
# finish automatically starts with newly-installed GUI

# # define download function
# # courtesy of http://fitnr.com/showing-file-download-progress-using-wget.html
# download()
# {
#     local url=$1
#     #    echo -n "    "
#     wget --progress=dot $url 2>&1 | grep --line-buffered "%" | \
    #         sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
#     #    echo -ne "\b\b\b\b"
#     #    echo " DONE"
# }

# Start verbose bash logging if signaled by presence of file
#sleep 3600
[[ -e /var/local/status/verbose ]] && set -x && set -v


# Populate About_This_Install directory with info specific to this run of the installer
myuser="econ-ark"
mypass="kra-noce"

# GitHub command line tools
/var/local/installers/install-gh-cli-tools.sh

# LaTeX - minimal
sudo apt -y install texlive-base

# Prepare for emacs install
sudo apt -y install xsel xclip # Allow interchange of clipboard with system
sudo apt -y install gpg gnutls-bin # Required to set up security for emacs package downloading

/var/local/installers/install-emacs.sh $myuser |& tee /var/local/status/install-emacs.log

commit_msg="$(cat /var/local/About_This_Install/commit-msg.txt)"
short_hash="$(cat /var/local/About_This_Install/short.git-hash)"
commit_date="$(cat /var/local/About_This_Install/commit_date)"

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

A copy of the ISO installer that generated this machine should be in the

    /installers

directory.

EOF

# # mdadm is for managing RAID systems but can cause backup problems; disable
# sudo apt -y remove mdadm

export DEBCONF_DEBUG=.*
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# # # The cups service sometimes gets stuck; stop it before that happens
# # sudo systemctl stop    cups-browsed.service 
# # sudo systemctl disable cups-browsed.service

# Manage software like dbus - seems to freeze finish.sh logging, so disabled
# sudo apt -y install software-properties-common

# Start the GUI if not already running
[[ "$(pgrep lightdm)" == '' ]] && service lightdm start 

# Packages present in "live" but not in "legacy" version of server
# https://ubuntuforums.org/showthread.php?t=2443047
sudo apt-get -y install cloud-init console-setup eatmydata gdisk libeatmydata1 

# More useful default tools 
sudo apt -y install build-essential module-assistant parted gparted xsel xclip cifs-utils nautilus exo-utils rclone autocutsel gnome-disk-utility rpl  net-tools network-manager snap evince nodejs

# Let root and myuser control networks
sudo adduser  $myuser netdev
sudo adduser  root    netdev

# Make a home for econ-ark in /usr/local/share/data and link to it from home directory
mkdir -p /home/$myuser/GitHub
mkdir -p          /root/GitHub

# Get to $myuser via ~/econ-ark whether you are root or econ-ark
ln -s /usr/local/share/data/GitHub/$myuser /home/$myuser/GitHub/econ-ark
ln -s /usr/local/share/data/GitHub/$myuser          /root/GitHub/econ-ark
chown -Rf $myuser:$myuser /home/$myuser/GitHub/$myuser
chown -Rf $myuser:$myuser /home/$myuser/GitHub/$myuser/.?*
chown -Rf $myuser:$myuser /usr/local/share/data/GitHub/$myuser # Make it be owned by $myuser user 

# branch_name="$(git symbolic-ref HEAD 2>/dev/null)"
# branch_name="${branch_name#refs/heads/}"

cd /var/local
branch_name="$(</var/local/status/git_branch)"
online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/"$branch_name"/Virtual/Machine/ISO-maker"

# Remove the linux automatically created directories like "Music" and "Pictures"
# Leave only required directories Downloads and Desktop
cd /home/$myuser

for d in ./*/; do
    if [[ ! "$d" == "./Downloads/" ]] && [[ ! "$d" == "./Desktop/" ]] && [[ ! "$d" == "./snap/" ]] && [[ ! "$d" == "./GitHub/" ]] ; then
	rm -Rf "$d"
    fi
done

# Play nice with Macs (in hopes of being able to monitor it)
# sudo apt -y install avahi-daemon avahi-discover avahi-utils libnss-mdns mdns-scan ifupdown
#sudo apt -y install at-spi2-core # Prevents some mysterious "AT-SPI" errors when apps are launched

# Start avahi so machine can be found on local network -- happens automatically in ubuntu
# mkdir -p /etc/avahi/
# # wget --quiet -O  /etc/avahi/ $online/Files/For-Target/root/etc/avahi/avahi-daemon.conf

# cp /var/local/root/etc/avahi/avahi-daemon.conf /etc/avahi
# Enable ssh over avahi
# cp /usr/share/doc/avahi-daemon/examples/ssh.service /etc/avahi/services


# Allow vnc (will only start up after reading ~/.bash_aliases)
# scraping server means that you're not allowing vnc client to spawn new x sessions
sudo apt -y install tigervnc-scraping-server

# If a previous version exists, delete it
[[ -e /home/$myuser/.vnc ]] && rm -Rf /home/$myuser/.vnc  
sudo -u $myuser mkdir -p /home/$myuser/.vnc

# https://askubuntu.com/questions/328240/assign-vnc-password-using-script

prog=/usr/bin/vncpasswd
sudo -u "$myuser" /usr/bin/expect <<EOF
spawn "$prog"
expect "Password:"
send "$mypass\r"
expect "Verify:"
send "$mypass\r"
expect "Would you like to enter a view-only password (y/n)?"
send "y\r"
expect "Password:"
send "$myuser-watch\r"
expect "Verify:"
send "$myuser-watch\r"
expect eof
exit
EOF

cd /home/$myuser/.vnc
echo "!/bin/sh" > xstartup
echo "xrdp $HOME/.Xresources" >> xstartup
echo "# startxfce4 & " >> xstartup
echo "# startxfce4 commented out because it should already have been started at boot " >> xstartup
sudo chmod a+x xstartup

# set defaults
default_hostname="$(</etc/hostname)"
default_domain=""

# Change the name of the host to the date and time of its creation
datetime="$(/var/local/status/build_date.txt)"

msg="$(cat /var/local/About_This_Install/commit-msg.txt)"
short_hash="$(cat /var/local/About_This_Install/short.git-hash)"
commit_date="$(cat /var/local/About_This_Install/commit_date)"

new_hostname="$commit_date-$short_hash"

if [[ "$default_hostname" == "-" ]]; then # not yet defined
    echo "$new_hostname" > /etc/hostname
    echo "$new_hostname" > /etc/hosts
else
    sed -i "s/$default_hostname/$new_hostname/g" /etc/hostname
    sed -i "s/$default_hostname/$new_hostname/g" /etc/hosts
fi

cd /home/"$myuser"

# Add stuff to bash login script

bashadd=/home/"$myuser"/.bash_aliases
[[ -e "$bashadd" ]] && mv "$bashadd" "$bashadd-orig"

ln -s /var/local/root/home/user_regular/bash_aliases "$bashadd"

# Make ~/.bash_aliases be owned by "$myuser" instead of root
chmod a+x "$bashadd"
chown $myuser:$myuser "$bashadd" 

# # The boot process looks for /EFI/BOOT directory and on some machines can use this stuff
# mkdir -p /EFI/BOOT/
if [[ -e /EFI/BOOT ]]; then
    cp /var/local/Disk/Labels/Econ-ARK.disk_label    /EFI/BOOT/.disk_label
    cp /var/local/Disk/Labels/Econ-ARK.disk_label_2x /EFI/BOOT/.disk_label2x
    echo 'Econ-ARK'    >                 /EFI/BOOT/.disk_label_contentDetails
fi

cd /var/local
size="MAX" # Default to max, unless there is a file named Size-To-Make-Is-MIN
[[ -e /var/local/status/Size-To-Make-Is-MIN ]] && size="MIN"

isoSize="$size"
welcome="# Welcome to the Econ-ARK Machine XUBUNTARK-$size, build "
welcome+="$(cat /var/local/About_This_Install/short.git-hash)"

cat <<EOF > XUBUNTARK.md
$welcome


This machine contains all the software necessary to use all parts of the
Econ-ARK toolkit.

EOF


# Download the installer (very meta!)
echo ''
echo 'Fetching online image of this installer to '
echo "/media/"

[[ -e "/media/*.iso" ]] && sudo rm "/media/*.iso"


# sudo pip  install gdown # Google download

cd /var/local

# Install Chrome browser 
wget --quiet -O /var/local/status/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install /var/local/status/google-chrome-stable_current_amd64.deb
sudo -u $myuser xdg-settings set default-web-browser google-chrome.desktop
xdg-settings set default-web-browser google-chrome.desktop

# Make sure that everything in the home user's path is owned by home user 
chown -Rf $myuser:$myuser /home/$myuser/

# bring system up to date
sudo apt -y update && sudo apt -y upgrade

# Signal that we've finished software install
touch /var/local/status/finished-software-install.flag 


if [[ "$size" == "MIN" ]]; then
    sudo apt -y install python3-pip python-pytest python-is-python3
    sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 10
    sudo pip install pytest
    sudo pip install nbval
    sudo pip install jupyterlab # jupyter notebook is no longer maintained
else
    sudo chmod +x /var/local/finish-MAX-Extras.sh
    sudo /var/local/finish-MAX-Extras.sh
    source /etc/environment # Update the path
    echo '' >> XUBUNTARK.md
    echo 'In addition, it contains a rich suite of other software (like LaTeX) widely ' >> XUBUNTARK.md
    echo 'used in scientific computing, including full installations of Anaconda, '     >> XUBUNTARK.md
    echo 'scipy, quantecon, and more.' >> XUBUNTARK.md
    echo '' >> XUBUNTARK.md
fi

cat /var/local/About_This_Install/XUBUNTARK-body.md >> /var/local/XUBUNTARK.md

mv /var/local/XUBUNTARK.md /var/local/About_This_Install

sudo pip install elpy
# Now that elpy has been installed, rerun the emacs setup to connect to it
emacs -batch -l     /home/econ-ark/.emacs  # Run in batch mode to setup everything

# 20220602: For some reason jinja2 version obained by pip install is out of date
sudo pip install jinja2

# Configure jupyter notebook tools

sudo pip install jupyter_contrib_nbextensions
sudo jupyter contrib nbextension install
sudo jupyter nbextension enable codefolding/main
sudo jupyter nbextension enable codefolding/edit
sudo jupyter nbextension enable toc2/main
sudo jupyter nbextension enable collapsible_headings/main
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo jupyter labextension install jupyterlab-jupytext
sudo pip install ipywidgets
sudo apt -y install nodejs

# Install systemwide copy of econ-ark 
sudo pip install --upgrade econ-ark
sudo pip install --upgrade nbreproduce

# elpy is for syntax checking in emacs
sudo pip install elpy

# Install user-owned copies of useful repos
# Download and extract HARK, REMARK, DemARK, econ-ark-tools from GitHub

# Allow reading of MacOS HFS+ files
sudo apt -y install hfsplus hfsutils hfsprogs

# # Prepare partition for reFind boot manager in MacOS
# hfsplusLabels="$(sudo sfdisk --list --output Device,Sectors,Size,Type,Attrs,Name | grep "HFS+" | awk '{print $1}')"

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install unattended-upgrades

sudo mkdir -p /etc/apt/apt.conf.d/20auto-upgrades
# # sudo wget -O  /etc/apt/apt.conf.d/20auto-upgrades $online/Files/For-Target/root/etc/apt/apt.conf.d/20auto-upgrades
sudo cp /var/local/root/etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades 

# Batch compile emacs so it will get all its packages
sudo -i -u  econ-ark emacs -batch -l     /home/econ-ark/.emacs  

# Restore printer services (disabled earlier because sometimes cause hang of boot)
sudo systemctl enable cups-browsed.service 

# Meld is a good file/folder diff tool
sudo apt -y install meld

/var/local/installers/install-ssh.sh "$myuser"    |& tee /var/local/status/install-ssh.log
#/var/local/config/config/config-keyring.sh "$myuser" |& tee /var/local/config/config-keyring.log

sudo apt -y upgrade

# Kill tail monitor if somehow it is still running
tail_monitor="$(pgrep tail)" && [[ ! -z "$tail_monitor" ]] && sudo kill "$tail_monitor"

sudo reboot
