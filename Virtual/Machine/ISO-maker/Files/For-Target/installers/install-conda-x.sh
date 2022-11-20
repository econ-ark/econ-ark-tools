#!/bin/bash

[[ -e /var/local/status/verbose ]] && set -x && set -v

# Install either miniconda or anaconda

if [[ "$#" -ne 1 ]]; then
    echo 'usage: $0 [anaconda|miniconda]'
    exit
fi

# In case they used capitals
export CHOSEN=$(echo $1 | tr '[:upper:]' '[:lower:]')
# CHOSEN=miniconda
ANA='anaconda' && MIN='miniconda'

[[ "$CHOSEN" != "$ANA" ]] && [[ "$CHOSEN" != "$MIN" ]] && bad_syntax=true
[[ "$CHOSEN" == "" ]] && echo "CHOSEN has no value; aborting" && exit

if [[ "$bad_syntax" == true ]]; then
    echo 'usage: install-conda-x.sh [anaconda|miniconda]'
    exit
fi

echo '' ; echo 'User must have sudoer privileges ...' ; echo ''
sudoer=false
sudo -v &> /dev/null && echo '... sudo privileges activated.' && sudoer=true
[[ "$sudoer" == "false" ]] && echo 'Exiting because sudoer privileges are not available.' && exit

# (wisely) gave up on automatically retrieving latest version
## 2022.05: Python version is 3.9
LATEST_ANA="$(</var/local/About_This_Install/anaconda_version)"
LATEST_MIN="$(</var/local/About_This_Install/miniconda_version)"

[[ "$CHOSEN" == "$ANA" ]] && NOT_CHOSEN="$MIN" && LATEST=$LATEST_ANA && URL="repo.anaconda.com/archive"
[[ "$CHOSEN" == "$MIN" ]] && NOT_CHOSEN="$ANA" && LATEST=$LATEST_MIN && URL="repo.anaconda.com/miniconda"

arch="$(uname -m)"
LATEST="$LATEST-$arch.sh"

# If installing one over the other, fix paths
sudo chmod a+rx /root
sudo chmod a+rx /root/.bashrc
sudo touch /root/.zshrc
sudo chmod a+rx /root/.zshrc

NOT_CHOSEN_CODE_EXISTS="$(grep $NOT_CHOSEN /root/.bashrc)"

# Prepare the destination
sudo rm -Rf /usr/local/$CHOSEN
sudo rm -Rf /usr/local/$NOT_CHOSEN

if [[ ! -e /tmp/$CHOSEN/$LATEST ]]; then # haven't downloaded it yet
    cmd="mkdir /tmp/$CHOSEN ; wget         -O /tmp/$CHOSEN/$LATEST https://$URL/$LATEST ; cd /tmp/$CHOSEN"
    sudo /bin/bash -c "$cmd" # do it
fi

# make installer executable
sudo chmod a+x /tmp/$CHOSEN/$LATEST

# install in "-b" batch mode at "-p" path
sudo /tmp/$CHOSEN/$LATEST -b -p /usr/local/$CHOSEN

# Get the new ~/.bashrc which should have conda in the path

# Init for root user
cd /root
sudo -u root cp -f /home/root/.bashrc /home/root/.bashrc_preconda    
sudo -u root cp -f /home/root/.zshrc  /home/root/.zshrc_preconda      
sudo -u root /usr/local/$CHOSEN/bin/conda init --system zsh    
sudo -u root /usr/local/$CHOSEN/bin/conda init --system bash 

# Init for every user
../config/config-conda.sh $CHOSEN

## Add to default environment path so that all users can find it
if [[ ! "$PATH" == *"/usr/local/$CHOSEN"* ]]; then # not in PATH
    echo 'Adding '$CHOSEN' to PATH in /etc/environment'

    sudo chmod u+w /etc/environment
    [[ -e /tmp/environment ]] && sudo rm -Rf /tmp/environment

    # Delete the not-chosen version from the path (if there)
    sudo sed -e 's\/usr/local/'$NOT_CHOSEN'/bin:\\g' /etc/environment > /tmp/environment
    sudo mv /etc/environment /etc/environment_orig_"$(date +%Y%m%d%H%M)"

    # Add chosen to universal path
    sudo sed -i -e "s\/usr/local/sbin:\/usr/local/"$CHOSEN"/bin:/usr/local/sbin:\g" /tmp/environment 

    # Execute conda.sh also in noninteractive bash shells
    CONDA_INIT_PATH=/etc/profile.d/conda.sh
    if [[ "$(grep BASH_ENV /tmp/environment)" ]]; then # dont add if already there
	echo "$CONDA_INIT_PATH was already in BASH_ENV"
    else
	echo "BASH_ENV=$CONDA_INIT_PATH" >> /tmp/environment
    fi

    sudo mv /tmp/environment /etc/environment

    # Replace original environment and fix permissions
    sudo chmod u-w /etc/environment* # Restore secure permissions for environment
fi

# Because installed as root, files are not executable by non-root users but should be
pushd .
cd /usr/local/$CHOSEN
sudo find . -type f -name "*\.sh"   -exec chmod a+x {} \;
sudo find . -type f -name "*\..sh"  -exec chmod a+x {} \; # Gets .csh, .zsh, whatever
sudo find . -type f -name "*\...sh" -exec chmod a+x {} \; # Gets .bash, .fish
popd

source /etc/environment
source ~/.bashrc
CONDA_PATH="$(which conda)"

# If conda command has no path, something went wrong
if [[ "$CONDA_PATH" == "" ]]; then
    echo $0 ' failed; exiting'
    exit 1
fi

# add /usr/local/$CHOSEN to secure path
[[ ! -e /etc/sudoers.d ]] && sudo mkdir -p /etc/sudoers.d && sudo chmod a+w /etc/sudoers.d
if [[ ! -e /etc/sudoers.d/$CHOSEN ]]; then
    # if the other version was previously active, deactivate it
    [[ -e /etc/sudoers.d/$NOT_CHOSEN ]] && rm -Rf /etc/sudoers.d/$NOT_CHOSEN
    # add this version
    sudo echo 'Defaults secure_path="/usr/local/'$CHOSEN'/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/snap/bin:/bin"' | sudo tee /etc/sudoers.d/$CHOSEN
fi

# Set permissions and ownership
sudo chmod 555 /etc/sudoers.d 
sudo groupadd conda &> /dev/null # probably already exists; but if not ...
sudo chgrp -R conda /usr/local/$CHOSEN # owned by group conda
sudo chmod g+rw     /usr/local/$CHOSEN # members can modify

## conda init puts the path to conda in user's ~/.bashrc
conda init --system bash    # For root user

echo ''
echo 'To use the newly installed conda, you must do a'
echo 'source ~/.bashrc'
echo ''
