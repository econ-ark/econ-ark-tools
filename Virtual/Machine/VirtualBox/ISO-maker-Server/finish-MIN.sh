#!/bin/bash
# Set username
myuser=econ-ark
# The cups service sometimes gets stuck; stop it before that happens
sudo systemctl stop cups-browsed.service 
sudo systemctl disable cups-browsed.service
# Update everything 
sudo apt -y update && sudo apt -y upgrade
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt -y install software-properties-common python3 python3-pip python-pytest
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 10
sudo apt -y python-pytest
sudo pip install nbval
# Get default packages for Econ-ARK machine
sudo apt -y install curl git bash-completion xsel cifs-utils openssh-server nautilus-share xclip gpg
# Create a public key for security purposes
sudo -u $myuser ssh-keygen -t rsa -b 4096 -q -N "" -C $myuser@XUBUNTU -f /home/@myuser/.ssh
# Set up security for emacs package downloading 
sudo apt -y install emacs
sudo -u econ-ark emacs -batch -l ~/.emacs --eval='(package-list-packages)'
sudo -u econ-ark mkdir -p /home/econ-ark/.emacs.d/elpa
sudo -u econ-ark mkdir -p /home/econ-ark/.emacs.d/elpa/gnupg
sudo -u econ-ark gpg --list-keys 
sudo -u econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa       --list-keys
sudo -u econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa/gnupg --list-keys
sudo -u econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa       --receive-keys 066DAFCB81E42C40
sudo -u econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa/gnupg --receive-keys 066DAFCB81E42C40

#Download and extract HARK, REMARK, DemARK from GitHUB repository

conda install --yes -c conda-forge econ-ark # pip install econ-ark

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

sudo -u econ-ark pip install jupyter_contrib_nbextensions
sudo -u econ-ark jupyter contrib nbextension install --user
cd /usr/local/share/data/GitHub/econ-ark/REMARK/binder ; pip install -r requirements.txt
cd /usr/local/share/data/GitHub/econ-ark/DemARK/binder ; pip install -r requirements.txt

# https://askubuntu.com/questions/499070/install-virtualbox-guest-addition-terminal

# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
[[ "$(which lshw)" ]] && vbox="$(lshw | grep VirtualBox) | grep VirtualBox"  && [[ "$vbox" != "" ]] && virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 && sudo adduser econ-ark vboxsf

sudo apt -y install build-essential module-assistant parted gparted

mkdir -p /home/econ-ark/GitHub ; ln -s /usr/local/share/data/GitHub/econ-ark /home/econ-ark/GitHub/econ-ark
chown econ-ark:econ-ark /home/econ-ark/GitHub
chown -Rf econ-ark:econ-ark /usr/local/share/data/GitHub/econ-ark # Make it be owned by econ-ark user 

sudo apt -y install hfsplus hfsutils hfsprogs

hfsplusLabels="$(sudo lsblk -o LABEL) | grep hfsplus" && [[ "$hfsplusLabels" != "" ]] && partn="$(sudo lsblk --list --o NAME,LABEL | grep hfsplus | awk '{print $1}')" && cmd=$"(mkfs.hfs -v 'HFS+' /dev/$partn" && echo "$cmd"

[[ "$hfsplusLabels" != "" ]] && sudo mkdir "/tmp/$partn" ; sudo mount -t hfsplus "/dev/$partn" "/tmp/$partn" ; cd "$/tmp/$partn" 

online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/$git_branch/Virtual/Machine/VirtualBox/ISO-maker-Server"

download()
{
    local url=$1
    echo -n "    "
    wget --progress=dot $url 2>&1 | grep --line-buffered "%" | \
        sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    echo -ne "\b\b\b\b"
    echo " DONE"
}

download "$online/refind-install-MacOS.sh"

chmod a+x *.sh


echo Finished automatic installations.  Rebooting.
reboot 
