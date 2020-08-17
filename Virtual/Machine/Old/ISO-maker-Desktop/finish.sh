#!/bin/bash
# Set username
myuser=econ-ark
# The cups service sometimes gets stuck; stop it before that happens
sudo systemctl stop cups-browsed.service 
sudo systemctl disable cups-browsed.service
# Update everything 
sudo apt -y update && sudo apt -y upgrade
# Extra packages for MAX
# Install anaconda3 for all users 
# Adapted from http://askubuntu.com/questions/505919/how-to-install-anaconda-on-ubuntu

sudo ls  > /dev/null # make sure we have root permission

# These have been copied from the preseed file because apparently ubiquity ignores them
# But realized that they don't work here; ubiquity/success_command seems to be a substitute for late_command
# so moved them to ubiquity ubiquity/success_command string

# online=https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker-Desktop
# finishFile="finish.sh"
# startFile="start.sh"
# seed_file="econ-ark.seed"
# ks_file=ks.cfg
# rclocal_file=rc.local


# curl -L -o /var/local/start.sh $online/$startFile
# curl -L -o /var/local/finish.sh $online/$finishFile
# curl -L -o /etc/rc.local $online/$rclocal_file
# chmod +x /var/local/start.sh
# chmod +x /var/local/finish.sh
# chmod +x /etc/rc.local
# mkdir -p /etc/lightdm/lightdm.conf.d
# curl -L -o /etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf $online/root/etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf
# chmod 755 /etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf


# Put in /tmp directory
[[ -e /tmp/Anaconda ]] && sudo rm -Rf /tmp/Anaconda # delete any prior install

mkdir /tmp/Anaconda ; cd /tmp/Anaconda

CONTREPO=https://repo.continuum.io/archive/
# Stepwise filtering of the html at $CONTREPO
# Get the topmost line that matches our requirements, extract the file name.
ANACONDAURL=$(wget -q -O - $CONTREPO index.html | grep "Anaconda3-" | grep "Linux" | grep "86_64" | head -n 1 | cut -d \" -f 2)
cmd="wget -O /tmp/Anaconda/$ANACONDAURL $CONTREPO$ANACONDAURL ; cd /tmp/Anaconda"
echo "$cmd"
eval "$cmd"

cmd="sudo rm -Rf /usr/local/anaconda3 ; chmod a+x /tmp/Anaconda/$ANACONDAURL ; /tmp/Anaconda/$ANACONDAURL -b -p /usr/local/anaconda3"
echo "$cmd"
eval "$cmd"

# Add to default enviroment path so that everyone can find it
addToPath='export PATH=/usr/local/anaconda3/bin:$PATH'
echo "$addToPath"
eval "$addToPath"
sudo chmod u+w /etc/environment
sudo sed -e 's\/usr/local/sbin:\/usr/local/anaconda3/bin:/usr/local/sbin:\g' /etc/environment > /tmp/environment

# eliminate any duplicates which may exist if the script has been run more than once
sudo sed -e 's\/usr/local/anaconda3/bin:/usr/local/anaconda3/bin\/usr/local/anaconda3/bin\g' /tmp/environment > /tmp/environment2

sudo mv /tmp/environment2 /etc/environment # Weird permissions issue prevents direct redirect into /etc/environment
sudo chmod u-w /etc/environment # Restore secure permissions for environment

if [ ! -e /etc/sudoers.d/anaconda3 ]; then # Modify secure path so that anaconda commands will work with sudo
    sudo mkdir -p /etc/sudoers.d
    sudo echo 'Defaults secure_path="/usr/local/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/snap/bin:/bin"' | sudo tee /etc/sudoers.d/anaconda3
fi

source /etc/environment  # Get the new environment

conda update --yes conda
conda update --yes anaconda

# Add some final common tools
conda install --yes -c anaconda scipy
conda install --yes -c anaconda pyopengl # Otherwise you get an error "Segmentation fault (core dumped)" on some Ubuntu machines
conda install --yes -c conda-forge jupyter_contrib_nbextensions

sudo pip install nbval
# Get default packages for Econ-ARK machine
sudo apt -y install curl git bash-completion xsel cifs-utils openssh-server nautilus-share xclip gpg
# Extra packages for MAX
sudo apt -y evince texlive-full quantecon scipy
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


# Get the full contents of the REMARK directory

cd /usr/local/share/data/GitHub/econ-ark/REMARK
git submodule update --init --recursive --remote
git pull --recurse-submodules

sudo -u econ-ark pip install jupyter_contrib_nbextensions
sudo -u econ-ark jupyter contrib nbextension install --user
# Extra nbextensions for MAX
sudo -u econ-ark jupyter nbextension enable codefolding/main
sudo -u econ-ark jupyter nbextension enable codefolding/edit
sudo -u econ-ark jupyter nbextension enable toc2/main
sudo -u econ-ark jupyter nbextension enable collapsible_headings/main
cd /usr/local/share/data/GitHub/econ-ark/REMARK/binder ; pip install -r requirements.txt

# https://askubuntu.com/questions/499070/install-virtualbox-guest-addition-terminal

sudo apt -y install build-essential module-assistant virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
mkdir -p /home/econ-ark/GitHub ; ln -s /usr/local/share/data/GitHub/econ-ark /home/econ-ark/GitHub/econ-ark
chown econ-ark:econ-ark /home/econ-ark/GitHub
chown -Rf econ-ark:econ-ark /usr/local/share/data/GitHub/econ-ark # Make it be owned by econ-ark user 
sudo adduser econ-ark vboxsf

echo Finished automatic installations.  Rebooting.
reboot 
