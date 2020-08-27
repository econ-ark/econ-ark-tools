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

sudo apt -y install meld autocutsel ca-certificates 

# The cups service sometimes gets stuck; stop it before that happens
sudo systemctl stop    cups-browsed.service 
sudo systemctl disable cups-browsed.service

sudo apt -y install software-properties-common # Manage software like dbus 

# More useful default tools 
sudo apt -y install build-essential module-assistant parted gparted xsel xclip cifs-utils

# Make a home for econ-ark in /usr/local/share/data and link to it from home directory
mkdir -p /home/econ-ark/GitHub
mkdir -p          /root/GitHub

# Get to econ-ark via ~/econ-ark whether you are root or econ-ark
ln -s /usr/local/share/data/GitHub/econ-ark /home/econ-ark/GitHub/econ-ark
ln -s /usr/local/share/data/GitHub/econ-ark          /root/GitHub/econ-ark
chown -Rf econ-ark:econ-ark /home/econ-ark/GitHub
chown -Rf econ-ark:econ-ark /usr/local/share/data/GitHub/econ-ark # Make it be owned by econ-ark user 

myuser="econ-ark"
mypass="kra-noce"

# branch_name="$(git symbolic-ref HEAD 2>/dev/null)"
# branch_name="${branch_name#refs/heads/}"

branch_name=master
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
sudo apt -y install avahi-daemon avahi-discover avahi-utils libnss-mdns mdns-scan ifupdown nss-mdns

# Start avahi so machine can be found on local network -- happens automatically in ubuntu
mkdir -p /etc/avahi/
wget -O  /etc/avahi $online/Files/For-Target/root/etc/avahi/avahi-daemon.conf
# Enable ssh over avahi
cp /usr/share/doc/avahi-daemon/examples/ssh.service /etc/avahi/services

# Get misc other stuff 
refindFile="refind-install-MacOS"
wget -O   /var/local/Econ-ARK.disk_label           $online/Disk/Labels/Econ-ARK.disklabel    
wget -O   /var/local/Econ-ARK.disk_label_2x        $online/Disk/Labels/Econ-ARK.disklabel_2x 
wget -O   /var/local/$refindFile.sh                $online/Files/For-Target/$refindFile.sh
wget -O   /var/local/$refindFile-README.md         $online/Files/For-Target/$refindFile-README.md
chmod +x  /var/local/$refindFile.sh
chmod a+r /var/local/$refindFile-README.md 

# Allow vnc (will only start up after reading ~/.bash_aliases)
# scraping server means that you're not allowing vnc client to spawn new x sessions
sudo apt -y install tigervnc-scraping-server

# If a previous version exists, delete it
[[ -e /home/$myuser/.vnc ]] && rm -Rf /home/$myuser/.vnc  
sudo mkdir -p /home/$myuser/.vnc

# https://askubuntu.com/questions/328240/assign-vnc-password-using-script

prog=/usr/bin/vncpasswd
/usr/bin/expect <<EOF
spawn "$prog"
expect "Password:"
send "$mypass\r"
expect "Verify:"
send "$mypass\r"
expect "Would you like to enter a view-only password (y/n)?"
send "y\r"
expect "Password:"
send "$mypass\r"
expect "Verify:"
send "$mypass\r"
expect eof
exit
EOF

# set defaults
default_hostname="$(hostname)"
default_domain=""

# Change the name of the host to the date and time of its creation
datetime="$(date +%Y%m%d%H%S)"
sed -i "s/xubuntu/$datetime/g" /etc/hostname
sed -i "s/xubuntu/$datetime/g" /etc/hosts

cd /home/"$myuser"

# Add stuff to bash login script

bashadd=/home/"$myuser"/.bash_aliases
[[ -e "$bashadd" ]] && mv "$bashadd" "$bashadd-orig"
touch "$bashadd"

cat /var/local/bash_aliases-add >> "$bashadd"

# Make ~/.bash_aliases be owned by "$myuser" instead of root
chmod a+x "$bashadd"
chown $myuser:$myuser "$bashadd" 

# The boot process looks for /EFI/BOOT directory and on some machines can use this stuff
mkdir -p /EFI/BOOT/
cp /var/local/Econ-ARK.disk_label    /EFI/BOOT/.disk_label
cp /var/local/Econ-ARK.disk_label_2x /EFI/BOOT/.disk_label2x
echo 'Econ-ARK'    >                 /EFI/BOOT/.disk_label_contentDetails

# Get other default packages for Econ-ARK machine
sudo apt -y install cifs-utils xclip xsel

cd /var/local
size="MAX" # Default to max, unless there is a file named Size-To-Make-Is-MIN
[[ -e ./Size-To-Make-Is-MIN ]] && size="MIN"

if [[ "$size" == "MIN" ]]; then
    sudo apt -y install python3-pip python-pytest python-is-python3
    sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 10
    sudo pip install    pytest
    sudo pip install nbval
    sudo pip install jupyterlab # jupyter is no longer maintained, and the latest version of matplotlib that jupyter_contrib_nbextensions uses does not work with python 3.8.
else
    sudo chmod +x /var/local/finish-MAX-Extras.sh
    cp /var/local/XUBUNTARK-MAX.md /var/local/XUBUNTARK.md
    sudo /var/local/finish-MAX-Extras.sh
 fi

# Configure jupyter notebook tools
sudo pip install jupyter_contrib_nbextensions
sudo jupyter contrib nbextension install
sudo jupyter nbextension enable codefolding/main
sudo jupyter nbextension enable codefolding/edit
sudo jupyter nbextension enable toc2/main
sudo jupyter nbextension enable collapsible_headings/main

#Download and extract HARK, REMARK, DemARK from GitHUB repository

pip install --upgrade econ-ark 

arkHome=/usr/local/share/data/GitHub/econ-ark
mkdir -p "$arkHome"
cd "$arkHome"
git clone https://github.com/econ-ark/REMARK.git
git clone https://github.com/econ-ark/HARK.git
git clone https://github.com/econ-ark/DemARK.git
git clone https://github.com/econ-ark/econ-ark-tools.git
chmod a+rw -Rf /usr/local/share/data/GitHub/econ-ark



echo 'This is your local, personal copy of HARK; it is also installed systemwide.  '    >  HARK-README.md
echo 'Local mods will not affect systemwide, unless you change the default source via:' >> HARK-README.md
echo "   cd $arkHOME ;  pip install -e setup.py "  >> HARK-README.md
echo '' >> HARK-README.md
echo '(You can switch back to the systemwide version using pip install econ-ark)' >> HARK-README.md
echo 'To test whether everything works, in the root directory type:.  '    >>  HARK-README.md
echo 'pytest '    >>  HARK-README.md

echo 'This is your local, personal copy of DemARK, which you can modify.  '    >  DemARK-README.md
echo 'To test whether everything works, in the root directory type:.  '    >>  DemARK-README.md
echo 'cd notebooks ; pytest --nbval-lax *.ipynb  '    >>  DemARK-README.md

echo 'This is your local, personal copy of REMARK, which you can modify.  '    >  REMARK-README.md

cd /usr/local/share/data/GitHub/econ-ark/REMARK
git submodule update --init --recursive --remote
git pull
cd /usr/local/share/data/GitHub/econ-ark/REMARK/binder ; pip install -r requirements.txt
cd /usr/local/share/data/GitHub/econ-ark/DemARK/binder ; pip install -r requirements.txt

cd /usr/local/share/data/GitHub/econ-ark/HARK
pytest

cd /usr/local/share/data/GitHub/econ-ark/DemARK
pytest

# Allow reading of MacOS HFS+ files
sudo apt -y install hfsplus hfsutils hfsprogs

# Prepare partition for reFind boot manager in MacOS
hfsplusLabels="$(sudo sfdisk --list --output Device,Sectors,Size,Type,Attrs,Name | grep "HFS+" | awk '{print $1}')"

echo "hfsplusLabels=$hfsplusLabels"
if [[ "$hfsplusLabels" != "" ]]; then                  # A partition LABELED HFS+ exists...
    cmd="mkfs.hfsplus -v 'refind-HFS' $hfsplusLabels"  # ... so FORMAT it as hfsplus
    echo "cmd=$cmd"
    eval "$cmd"
    sudo mkdir /tmp/refind-HFS && sudo mount -t hfsplus "$hfsplusLabels" /tmp/refind-HFS  # Mount the new partition in /tmp/refind-HFS
    sudo cp /var/local/refind-install-MacOS.sh    /tmp/refind-HFS      # Put refind script on the partition
    sudo chmod a+x                                /tmp/refind-HFS/*.sh # make it executable
    sudo cp /var/local/Econ-ARK.VolumeIcon.icns   /tmp/refind-HFS/.VolumeIcon.icns # Should endow the HFS+ volume with the Econ-ARK logo
    echo  "$online/Disk/Icons/.VolumeIcon.icns" > /tmp/refind-HFS/.VolumeIcon_icns.source
#    sudo wget -O  /tmp/refind-HFS/.VolumeIcon.icns "$online/Disk/Icons/os_refit.icns" 
#    echo  "$online/Disk/Icons/os_refit.icns" >   /tmp/refind-HFS/.VolumeIcon_icns.source
    # hfsplusLabels="$(sudo sfdisk --list --output Device,Sectors,Size,Type,Attrs,Name | grep "HFS+" | awk '{print $1}')"
    # sudo apt-get --assume-no install refind # If they might be booting from MacOS or Ubuntu, make refind the base bootloader
    # ESP=$(sudo sfdisk --list | grep EFI | awk '{print $1}')
    # sudo refind-install --usedefault "$ESP"
fi

# Download the installer (very meta!)
isoName="econ-ark_$size_ubuntu-20.04-legacy-server-amd64-unattended.iso"
echo ''
echo 'Fetching online image of this installer to '
echo "/media/$isoName"

[[ -e "/media/$isoName" ]] && sudo rm "/media/$isoName"
pip  install gdown # Google download

if [ "$size" == "MIN" ]; then
    gdown --id "19AL7MsaFkTdFA1Uuh7gE57Ksshle2RRR" --output "/media/$isoName"
else # size = MAX
    gdown --id "1Qs8TpId5css7q9L315VUre0mjIRqjw8Z" --output "/media/$isoName"
fi

# Install Chrome browser 
wget -O          /var/local/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install /var/local/google-chrome-stable_current_amd64.deb

# Make sure that everything in the home user's path is owned by home user 
chown -Rf $myuser:$myuser /home/$myuser/

# bring system up to date
sudo apt -y update && sudo apt -y upgrade  

# Signal that we've finished software install
touch /var/local/finished-software-install 

# Restore printer services (disabled earlier because sometimes cause hang of boot)
sudo systemctl enable cups-browsed.service 

reboot
