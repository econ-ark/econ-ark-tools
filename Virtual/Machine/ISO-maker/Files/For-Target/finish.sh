#!/bin/bash
# start.sh installs GUI then reboots;
# finish automatically starts with newly-installed GUI

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

# Set up bash verbose debugging
set -x ; set -v

export DEBCONF_DEBUG=.*
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# The cups service sometimes gets stuck; stop it before that happens
sudo systemctl stop    cups-browsed.service 
sudo systemctl disable cups-browsed.service

# Manage software like dbus 
sudo apt -y install software-properties-common

# Allow controlling settings
sudo apt -y install xfce4-settings

# Meld is a good file/folder diff tool
sudo apt -y install meld

# More useful default tools 
sudo apt -y install build-essential module-assistant parted gparted xsel xclip cifs-utils nautilus exo-utils rclone autocutsel ca-certificates

# Make a home for econ-ark in /usr/local/share/data and link to it from home directory
mkdir -p /home/econ-ark/GitHub
mkdir -p          /root/GitHub

# Get to econ-ark via ~/econ-ark whether you are root or econ-ark
ln -s /usr/local/share/data/GitHub/econ-ark /home/econ-ark/GitHub/econ-ark
ln -s /usr/local/share/data/GitHub/econ-ark          /root/GitHub/econ-ark
chown -Rf econ-ark:econ-ark /home/econ-ark/GitHub/econ-ark
chown -Rf econ-ark:econ-ark /home/econ-ark/GitHub/econ-ark/.?*
chown -Rf econ-ark:econ-ark /usr/local/share/data/GitHub/econ-ark # Make it be owned by econ-ark user 

myuser="econ-ark"
mypass="kra-noce"

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
sudo apt -y install at-spi2-core # Prevents some mysterious "AT-SPI" errors when apps are launched

# Start avahi so machine can be found on local network -- happens automatically in ubuntu
mkdir -p /etc/avahi/
wget --quiet -O  /etc/avahi/ $online/Files/For-Target/root/etc/avahi/avahi-daemon.conf
# Enable ssh over avahi
cp /usr/share/doc/avahi-daemon/examples/ssh.service /etc/avahi/services

# Get misc other stuff 
#refindFile="refind-install-MacOS"
wget -O   /var/local/Econ-ARK.disk_label           $online/Disk/Labels/Econ-ARK.disklabel    
wget -O   /var/local/Econ-ARK.disk_label_2x        $online/Disk/Labels/Econ-ARK.disklabel_2x 
# wget -O   /var/local/$refindFile.sh                $online/Files/For-Target/$refindFile.sh
# wget -O   /var/local/$refindFile-README.md         $online/Files/For-Target/$refindFile-README.md
# chmod +x  /var/local/$refindFile.sh
# chmod a+r /var/local/$refindFile-README.md
#wget --quiet -O /var/local/zoom_amd64.deb $online/Files/ForTarget/zoom_amd64.deb 
wget --quiet -O /var/local/zoom_amd64.deb https://zoom.us/client/latest/zoom_amd64.deb


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
echo "startxfce4 & " >> xstartup
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
# cp /var/local/Econ-ARK.disk_label    /EFI/BOOT/.disk_label
# cp /var/local/Econ-ARK.disk_label_2x /EFI/BOOT/.disk_label2x
# echo 'Econ-ARK'    >                 /EFI/BOOT/.disk_label_contentDetails

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
sudo apt install /var/local/google-chrome-stable_current_amd64.deb
sudo -u econ-ark xdg-settings set default-web-browser google-chrome.desktop
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

arkHome=/usr/local/share/data/GitHub/econ-ark
mkdir -p "$arkHome"
sudo chown econ-ark:econ-ark $arkHome

cd "$arkHome"

for repo in REMARK HARK DemARK; do
    [[ -e "$repo" ]] && sudo rm -Rf "$repo" 
    sudo -u econ-ark git clone --depth 1 https://github.com/econ-ark/$repo
    # Make it all owned by the econ-ark user -- including invisible files like .git
    # Install all requirements
    [[ -e $repo/requirements.txt ]] && sudo pip install -r $repo/requirements.txt
    [[ -e $repo/binder/requirements.txt ]] && sudo pip install -r $repo/binder/requirements.txt
done

echo 'This is your local, personal copy of HARK; it is also installed systemwide.  '      >  HARK-README.md
echo 'Local mods will not affect systemwide, unless you change the default source via:'   >> HARK-README.md
echo "   cd $arkHOME ;  pip install -e setup.py "                                         >> HARK-README.md
echo '' >> HARK-README.md
echo '(You can switch back to the systemwide version using pip install econ-ark)'         >> HARK-README.md
echo 'To test whether everything works, in the root directory type:.  '                   >> HARK-README.md
echo 'pytest '                                                                            >> HARK-README.md

echo 'This is your local, personal copy of DemARK, which you can modify.  '    >  DemARK-README.md
echo 'To test whether everything works, in the root directory type:.  '       >>  DemARK-README.md
echo 'cd notebooks ; pytest --nbval-lax --ignore=Chinese-Growth.ipynb *.ipynb  '                            >>  DemARK-README.md

echo 'This is your local, personal copy of REMARK, which you can modify.  '    >  REMARK-README.md

# Run the automated tests to make sure everything installed properly
cd /usr/local/share/data/GitHub/econ-ark/HARK
pytest 

cd /usr/local/share/data/GitHub/econ-ark/DemARK/notebooks
# 20220508: Chinese-Growth is very slow
pytest --nbval-lax --ignore-glob='Chinese*.*' --nbval-cell-timeout=120 *.ipynb

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
sudo wget -O  /etc/apt/apt.conf.d/20auto-upgrades $online/Files/For-Target/root/etc/apt/apt.conf.d/20auto-upgrades

# Batch compile emacs so it will get all its packages
sudo -i -u  econ-ark emacs -batch -l     /home/econ-ark/.emacs  

# Restore printer services (disabled earlier because sometimes cause hang of boot)
sudo systemctl enable cups-browsed.service 

tail_monitor="$(pgrep tail)" && [[ ! -z "$tail_monitor" ]] && sudo kill "$tail_monitor"
reboot
