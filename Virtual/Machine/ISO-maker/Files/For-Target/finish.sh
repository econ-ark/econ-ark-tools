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
[[ -e /var/local/verbose ]] && set -x && set -v

# Populate About_This_Install directory with info specific to this run of the installer
myuser="econ-ark"
mypass="kra-noce"

cd /var/local

# ./install-xubuntu-desktop.sh  # plus some utilities and backdrop

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

A copy of the ISO installer that generated this machine should be in the

    /installers

directory.

EOF


# # mdadm is for managing RAID systems but can cause backup problems; disable
# sudo apt -y remove mdadm

# export DEBCONF_DEBUG=.*
# export DEBIAN_FRONTEND=noninteractive
# export DEBCONF_NONINTERACTIVE_SEEN=true

# # # The cups service sometimes gets stuck; stop it before that happens
# # sudo systemctl stop    cups-browsed.service 
# # sudo systemctl disable cups-browsed.service

# Manage software like dbus - seems to freeze finish.sh logging, so disabled
# sudo apt -y install software-properties-common

/var/local/install-ssh.sh "$myuser"    |& tee /var/local/install-ssh.log
/var/local/config-keyring.sh "$myuser" |& tee /var/local/config-keyring.log

# Start the GUI if not already running
[[ "$(pgrep lightdm)" == '' ]] && service lightdm start 

# Packages present in "live" but not in "legacy" version of server
# https://ubuntuforums.org/showthread.php?t=2443047
sudo apt-get -y install cloud-init console-setup eatmydata gdisk libeatmydata1 

# Meld is a good file/folder diff tool
sudo apt -y install meld

# More useful default tools 
sudo apt -y install build-essential module-assistant parted gparted xsel xclip cifs-utils nautilus exo-utils rclone autocutsel gnome-disk-utility 


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
branch_name="$(<git_branch)"
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
sudo apt -y install avahi-daemon avahi-discover avahi-utils libnss-mdns mdns-scan ifupdown
#sudo apt -y install at-spi2-core # Prevents some mysterious "AT-SPI" errors when apps are launched

# Start avahi so machine can be found on local network -- happens automatically in ubuntu
# mkdir -p /etc/avahi/
# # wget --quiet -O  /etc/avahi/ $online/Files/For-Target/root/etc/avahi/avahi-daemon.conf

# cp /var/local/root/etc/avahi/avahi-daemon.conf /etc/avahi
# Enable ssh over avahi
cp /usr/share/doc/avahi-daemon/examples/ssh.service /etc/avahi/services

# Get misc other stuff 
#refindFile="refind-install-MacOS"
#wget -O   /var/local/Econ-ARK.disk_label           $online/Disk/Labels/Econ-ARK.disklabel    
#wget -O   /var/local/Econ-ARK.disk_label_2x        $online/Disk/Labels/Econ-ARK.disklabel_2x 
# wget -O   /var/local/$refindFile.sh                $online/Files/For-Target/$refindFile.sh
# wget -O   /var/local/$refindFile-README.md         $online/Files/For-Target/$refindFile-README.md
# chmod +x  /var/local/$refindFile.sh
# chmod a+r /var/local/$refindFile-README.md
#wget --quiet -O /var/local/zoom_amd64.deb $online/Files/ForTarget/zoom_amd64.deb 
#wget --quiet -O /var/local/zoom_amd64.deb https://zoom.us/client/latest/zoom_amd64.deb


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
default_hostname="$(hostname)"
default_domain=""

# Change the name of the host to the date and time of its creation
datetime="$(date +%Y%m%d%H%S)"

msg="$(cat ./About_This_Install/commit-msg.txt)"
short_hash="$(cat ./About_This_Install/short.git-hash)"
commit_date="$(cat ./About_This_Install/commit_date)"

new_hostname="$commit_date-$short_hash"
sed -i "s/$default_hostname/$new_hostname/g" /etc/hostname
sed -i "s/$default_hostname/$new_hostname/g" /etc/hosts

cd /home/"$myuser"

# Add stuff to bash login script

bashadd=/home/"$myuser"/.bash_aliases
[[ -e "$bashadd" ]] && mv "$bashadd" "$bashadd-orig"
touch "$bashadd"

cat /var/local/bash_aliases-add >> "$bashadd"

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
[[ -e ./Size-To-Make-Is-MIN ]] && size="MIN"

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
wget --quiet -O          /var/local/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install /var/local/google-chrome-stable_current_amd64.deb
sudo -u $myuser xdg-settings set default-web-browser google-chrome.desktop
xdg-settings set default-web-browser google-chrome.desktop

# Make sure that everything in the home user's path is owned by home user 
chown -Rf $myuser:$myuser /home/$myuser/

# bring system up to date
sudo apt -y update && sudo apt -y upgrade

# Signal that we've finished software install
touch /var/local/finished-software-install 


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

sudo pip install elpy
cat /var/local/XUBUNTARK-body.md >> /var/local/XUBUNTARK.md

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

# echo "hfsplusLabels=$hfsplusLabels"
# if [[ "$hfsplusLabels" != "" ]]; then                  # A partition LABELED HFS+ exists...
#     cmd="mkfs.hfsplus -s -v 'refind-HFS' $hfsplusLabels"  # ... so FORMAT it as hfsplus
#     echo "cmd=$cmd"
#     eval "$cmd"
#     sudo mkdir /tmp/refind-HFS && sudo mount -t hfsplus "$hfsplusLabels" /tmp/refind-HFS  # Mount the new partition in /tmp/refind-HFS
#     sudo cp /var/local/refind-install-MacOS.sh    /tmp/refind-HFS      # Put refind script on the partition
#     sudo chmod a+x                                /tmp/refind-HFS/*.sh # make it executable
#     sudo cp /var/local/Econ-ARK.VolumeIcon.icns   /tmp/refind-HFS/.VolumeIcon.icns # Should endow the HFS+ volume with the Econ-ARK logo
#     echo  "$online/Disk/Icons/.VolumeIcon.icns" > /tmp/refind-HFS/.VolumeIcon_icns.source
#     #    sudo wget --quiet -O  /tmp/refind-HFS/.VolumeIcon.icns "$online/Disk/Icons/os_refit.icns" 
#     #    echo  "$online/Disk/Icons/os_refit.icns" >   /tmp/refind-HFS/.VolumeIcon_icns.source
#     # hfsplusLabels="$(sudo sfdisk --list --output Device,Sectors,Size,Type,Attrs,Name | grep "HFS+" | awk '{print $1}')"
#     # sudo apt-get --assume-no install refind # If they might be booting from MacOS or Ubuntu, make refind the base bootloader
#     # ESP=$(sudo sfdisk --list | grep EFI | awk '{print $1}')
#     # sudo refind-install --usedefault "$ESP"
# fi

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

tail_monitor="$(pgrep tail)" && [[ ! -z "$tail_monitor" ]] && sudo kill "$tail_monitor"

sudo reboot
