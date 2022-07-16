#!/bin/bash

bad_syntax=false

[[ "$#" -ne 1 ]] && bad_syntax=true

# In case they used capitals
CHOSEN=$(echo $1 | tr '[:upper:]' '[:lower:]')
# CHOSEN=miniconda
ANA='anaconda' && MIN='miniconda'

echo $CHOSEN
[[ "$CHOSEN" != "$ANA" ]] && [[ "$CHOSEN" != "$MIN" ]] && bad_syntax=true

if [[ "$bad_syntax" == true ]]; then
    echo 'usage: install-conda-x.sh [ anaconda | miniconda ]'
    exit
fi

# Put $CHOSEN in /tmp directory
[[ -e /tmp/$CHOSEN ]] && sudo rm -Rf /tmp/$CHOSEN # delete any prior install
mkdir /tmp/$CHOSEN ; cd /tmp/$CHOSEN

# (wisely) gave up on automatically retrieving latest version
## 2021.11: Python version is 3.9
[[ "$CHOSEN" == "$ANA" ]] && LATEST="Anaconda3-2021.11-Linux-x86_64.sh" && URL="repo.anaconda.com/archive"
[[ "$CHOSEN" == "$MIN" ]] && LATEST="Miniconda3-py39_4.12.0-Linux-x86_64.sh" && URL="repo.anaconda.com"

cmd="wget         -O /tmp/$CHOSEN/$LATEST https://$URL/$LATEST ; cd /tmp/$CHOSEN"
echo "$cmd" # show it
eval "$cmd" # do it

# Prepare the destination
sudo rm -Rf /usr/local/$CHOSEN

# make executable
sudo chmod a+x /tmp/$CHOSEN/$LATEST

# install in "-b" batch mode at "-p" path
/tmp/$CHOSEN/$LATEST -b -p /usr/local/$CHOSEN

# Add to default enviroment path so that all users can find it
source /etc/environment

if [[ ! "$PATH" == *"/usr/local/$CHOSEN"* ]]; then # not in PATH
    echo 'Adding '$CHOSEN' to PATH'
    sudo chmod u+w /etc/environment
    sudo rm -Rf /tmp/environment
    # Delete the not-chosen version from the path (if there)
    sudo sed -e 's\/usr/local/'$NOT_CHOSEN'/bin:\\g' /etc/environment > /tmp/environment
    # Add chosen to path
    sudo sed -e "s\/usr/local/sbin:\/usr/local/"$CHOSEN"/bin:/usr/local/sbin:\g" /tmp/environment > /tmp/environment2
    # Replace original environment and fix permissions
    sudo mv /tmp/environment2 /etc/environment # Weird permissions issue prevents direct redirect into /etc/environment
    sudo chmod u-w /etc/environment # Restore secure permissions for environment
    # This is done below
    # # source /etc/environment
    # # conda init bash
    # # sudo -u econ-ark      conda init bash
    # # sudo -u econ-ark-xrdp conda init bash
fi

# Pull in the modified environment
source /etc/environment  # Get the new environment

# CHOSEN user should have security permissions
[[ ! -e /etc/sudoers.d ]] && sudo mkdir -p /etc/sudoers.d && sudo chmod a+w /etc/sudoers.d
if [[ ! -e /etc/sudoers.d/$CHOSEN ]]; then
    sudo echo 'Defaults secure_path="/usr/local/'$CHOSEN'/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/snap/bin:/bin"' | sudo tee /etc/sudoers.d/$CHOSEN
fi
sudo chmod 555 /etc/sudoers.d # restore proper permissions
sudo group add conda
sudo chgrp -R conda /usr/local/$CHOSEN

# conda init puts the path to conda in user's ~/.bashrc
pushd . 
cd /home
for dir in */; do
    user=$(basename $dir)
    sudo adduser "$user" conda # Let all users manipulate conda
    cmd="sudo -u $user "$(which conda)$" init bash"
    eval "$cmd"
done
popd    
source ~/.bashrc  # Update environment with new change

# Because installed as root, files are not executable by non-root users but should be
pushd .
cd /usr/local/$CHOSEN
sudo find . -type f -iname ".sh"  -exec chmod a+x {} \;
sudo find . -type f -iname "..sh" -exec chmod a+x {} \; # Gets csh, zsh, whatever
popd

conda install --yes -c conda-forge mamba
conda activate base

# Add some final common tools
conda install --yes -c conda-forge jupyter_contrib_nbextensions
