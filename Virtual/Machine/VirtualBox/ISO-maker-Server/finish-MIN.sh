#!/bin/bash
# Set username
myuser=econ-ark
# The cups service sometimes gets stuck; stop it before that happens
sudo systemctl stop cups-browsed.service 
sudo systemctl disable cups-browsed.service

# Install xubuntu desktop causes problems having to do with requirement to answer a question which can't figure out how to preseed about which display manager to use
# sudo apt -y install xubuntu-desktop # but the xubuntu-desktop, at least, is not

# Update everything 
sudo apt -y update && sudo apt -y upgrade
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt -y install software-properties-common python3 python3-pip python-pytest
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 10
sudo python-pytest
sudo -i -u econ-ark python-pytest
sudo pip install nbval
# Get default packages for Econ-ARK machine
sudo apt -y install curl git bash-completion cifs-utils openssh-server xclip xsel gpg
# Create a public key for security purposes
sudo -i -u  $myuser ssh-keygen -t rsa -b 4096 -q -N "" -C $myuser@XUBUNTU -f /home/myuser/.ssh
# Set up security for emacs package downloading 
sudo apt -y install emacs
sudo -i -u  econ-ark mkdir -p /home/econ-ark/.emacs.d/elpa
sudo -i -u  econ-ark mkdir -p /home/econ-ark/.emacs.d/elpa/gnupg
sudo chown econ-ark:econ-ark /home/econ-ark/.emacs
sudo chown econ-ark:econ-ark -Rf /home/econ-ark/.emacs.d
sudo -i -u  econ-ark gpg --list-keys 
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa       --list-keys
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa/gnupg --list-keys
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa       --receive-keys 066DAFCB81E42C40
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa/gnupg --receive-keys 066DAFCB81E42C40
sudo -i -u  econ-ark emacs -batch -l     ~/.emacs 
sudo emacs -batch -l /root/.emacs 

#Download and extract HARK, REMARK, DemARK from GitHUB repository

pip install econ-ark # pip install econ-ark

# Set the timing for password login from screensaver
sudo apt -y install rpl # rpl is dangerous but useful

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
echo 'To test whether everything works, in the root directory type:.  '    >  HARK-README.md
echo 'pytest '    >  HARK-README.md


echo 'This is your local, personal copy of DemARK, which you can modify.  '    >  DemARK-README.md
echo 'To test whether everything works, in the root directory type:.  '    >  DemARK-README.md
echo 'cd notebooks ; pytest --nbval-lax *.ipynb  '    >  DemARK-README.md

echo 'This is your local, personal copy of REMARK, which you can modify.  '    >  REMARK-README.md

echo '' 
echo '' 
echo '' 
echo '' 
echo '' 
echo 'whoami='$(whoami)
echo ''
pip install jupyter_contrib_nbextensions
pip install jupyter contrib nbextension install --user
pip install jupyterlab # jupyter is no longer maintained, and the latest version of matplotlib that jupyter_contrib_nbextensions uses does not work with python 3.8.

cd /usr/local/share/data/GitHub/econ-ark/REMARK/binder ; pip install -r requirements.txt
cd /usr/local/share/data/GitHub/econ-ark/DemARK/binder ; pip install -r requirements.txt

# https://askubuntu.com/questions/499070/install-virtualbox-guest-addition-terminal

# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
[[ "$(which lshw)" ]] && vbox="$(lshw | grep VirtualBox) | grep VirtualBox"  && [[ "$vbox" != "" ]] && sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 && sudo adduser econ-ark vboxsf

sudo apt -y install build-essential module-assistant parted gparted

mkdir -p /home/econ-ark/GitHub ; ln -s /usr/local/share/data/GitHub/econ-ark /home/econ-ark/GitHub/econ-ark
chown econ-ark:econ-ark /home/econ-ark/GitHub
chown -Rf econ-ark:econ-ark /usr/local/share/data/GitHub/econ-ark # Make it be owned by econ-ark user 

sudo apt -y install hfsplus hfsutils hfsprogs

# Prepare partition for reFind boot in MacOS
hfsplusLabels="$(sudo sfdisk --list --output Device,Sectors,Size,Type,Attrs,Name | grep "HFS+" | awk '{print $1}')"

# If you want to pop up an informative window at this stage, you must set the environment variables below:
# export DISPLAY=:0.0
# export XAUTHORITY=/home/econ-ark/.Xauthority
# export SESSION_MANAGER="$(cat /tmp/SM)"
# xhost SI:localhost:root

echo "hfsplusLabels=$hfsplusLabels"
if [[ "$hfsplusLabels" != "" ]]; then
    cmd="mkfs.hfsplus -v 'refind-HFS' $hfsplusLabels"
    echo "cmd=$cmd"
    sudo mkfs.hfsplus -v 'refind-HFS' "$hfsplusLabels"
    sudo mkdir /tmp/refind-HFS && sudo mount -t hfsplus "$hfsplusLabels" /tmp/refind-HFS
    sudo cp /home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/VirtualBox/ISO-maker-Server/refind-install-MacOS.sh /tmp/refind-HFS
    sudo cp /var/local/Econ-ARK.VolumeIcon.icns /tmp/refind-HFS/.VolumeIcon.icns
    sudo cp /var/local/Econ-ARK.VolumeIcon.icns /.VolumeIcon.icns
    sudo chmod a+x /tmp/refind-HFS/*.sh
    sudo curl -L -o https://github.com/econ-ark/econ-ark-tools/blob/master/Virtual/Machine/VirtualBox/ISO-maker-Server/Disk/Icons/os_refit.icns /tmp/refind-HFS/.VolumeIcon.icns
    # hfsplusLabels="$(sudo sfdisk --list --output Device,Sectors,Size,Type,Attrs,Name | grep "HFS+" | awk '{print $1}')"
    # sudo apt-get --assume-no install refind # If they might be booting from MacOS or Ubuntu, make refind the base bootloader
    # ESP=$(sudo sfdisk --list | grep EFI | awk '{print $1}')
    # sudo refind-install --usedefault "$ESP"
fi

sudo apt-get -y purge gdm
sudo apt-get -y purge gdm3

# sudo apt -y install xubuntu-desktop 

DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* sudo apt -y install xubuntu-desktop  # Not sure why this isn't installed by presee
d

DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true DEBCONF_DEBUG=.* dpkg-reconfigure lightdm
echo set shared/default-x-display-manager lightdm | debconf-communicate 

sudo apt -y install xscreensaver 

if [[ -e /etc/X11/app-defaults/XScreenSaver-nogl ]]; then
    sudo chmod u+w /etc/X11/app-defaults/XScreenSaver-nogl
    sudo rpl 'passwdTimeout:		0:00:30' 'passwdTimeout:		0:02:30' /etc/X11/app-defaults/XScreenSaver-nogl
    sudo chmod u-w /etc/X11/app-defaults/XScreenSaver-nogl
else
    echo ''
    echo '/etc/X11/app-defaults/XScreenSaver-nogl config not found, so screensaver timer not reset'
    echo 'continuing'
    echo ''
fi


# sudo apt-get install firmware-b43-installer

reboot 
