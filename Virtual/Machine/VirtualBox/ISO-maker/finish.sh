#!/bin/bash
# Update everything 
sudo apt -y update && sudo apt -y upgrade
# Install anaconda3 for all users 
# Adapted from http://askubuntu.com/questions/505919/how-to-install-anaconda-on-ubuntu

sudo ls  > /dev/null # make sure we have root permission

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

# Get default packages for Econ-ARK machine
sudo apt -y install git bash-completion xsel cifs-utils openssh-server nautilus-share xclip texlive-full emacs auctex

#Download and extract HARK, REMARK, DemARK from GitHUB repository

conda install --yes -c conda-forge econ-ark
arkHome=/usr/local/share/GitHub/econ-ark
mkdir -p "$arkHome"
cd "$arkHome"
git clone https://github.com/econ-ark/REMARK.git
git clone https://github.com/econ-ark/DemARK.git

# https://askubuntu.com/questions/499070/install-virtualbox-guest-addition-terminal

sudo apt -y install build-essential module-assistant virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
mkdir -p /home/econ-ark/GitHub/econ-ark ; ln -s /usr/local/share/GitHub/econ-ark /home/econ-ark/GitHub/econ-ark
chown -Rf econ-ark:econ-ark /usr/local/share/GitHub/econ-ark # Make it be owned by econ-ark user 

echo Finished automatic installations.  Rebooting.
reboot 
