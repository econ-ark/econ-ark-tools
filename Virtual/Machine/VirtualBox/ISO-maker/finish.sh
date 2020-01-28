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
# Get default packages for Econ-ARK machine
sudo apt -y install curl git bash-completion xsel cifs-utils openssh-server nautilus-share xclip gpg nbval
# Create a public key for security purposes
sudo -u $myuser ssh-keygen -t rsa -b 4096 -q -N "" -C $myuser@XUBUNTU -f /home/econ-ark/.ssh/id_rsa
# Set up security for emacs package downloading 
sudo apt -y install emacs
sudo -u econ-ark gpg --list-keys 
sudo -u econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa/gnupg --receive-keys 066DAFCB81E42C40

#Download and extract HARK, REMARK, DemARK from GitHUB repository

conda install --yes -c conda-forge econ-ark # pip install econ-ark

arkHome=/usr/local/share/data/GitHub/econ-ark
mkdir -p "$arkHome"
cd "$arkHome"
git clone https://github.com/econ-ark/REMARK.git
git clone https://github.com/econ-ark/HARK.git
git clone https://github.com/econ-ark/DemARK.git
chmod a+rw -Rf /usr/local/share/data/GitHub/econ-ark

echo 'This is your local, personal copy of HARK; it is also installed systemwide.  '    >  HARK-README.md
echo 'Local mods will not affect systemwide, unless you change the default source via:' >> HARK-README.md
echo "   cd $arkHOME ;  pip install -e setup.py "  >> HARK-README.md
echo '' >> HARK-README.md
echo '(You can switch back to the systemwide version using pip install econ-ark)' >> HARK-README.md


echo 'This is your local, personal copy of DemARK, which you can modify.  '    >  DemARK-README.md
echo 'This is your local, personal copy of REMARK, which you can modify.  '    >  REMARK-README.md

sudo -u econ-ark pip install jupyter_contrib_nbextensions
sudo -u econ-ark jupyter contrib nbextension install --user
cd /usr/local/share/data/GitHub/econ-ark/REMARK/binder ; pip install -r requirements.txt

# https://askubuntu.com/questions/499070/install-virtualbox-guest-addition-terminal

sudo apt -y install build-essential module-assistant virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
mkdir -p /home/econ-ark/GitHub ; ln -s /usr/local/share/data/GitHub/econ-ark /home/econ-ark/GitHub/econ-ark
chown econ-ark:econ-ark /home/econ-ark/GitHub
chown -Rf econ-ark:econ-ark /usr/local/share/data/GitHub/econ-ark # Make it be owned by econ-ark user 

echo Finished automatic installations.  Rebooting.
reboot 
