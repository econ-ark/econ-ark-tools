#!/bin/bash

# Install either miniconda or anaconda

bad_syntax=false

[[ "$#" -ne 1 ]] && bad_syntax=true  # one argument

# In case they used capitals
CHOSEN=$(echo $1 | tr '[:upper:]' '[:lower:]')

ANA='anaconda' && MIN='miniconda'

[[ "$CHOSEN" != "$ANA" ]] && [[ "$CHOSEN" != "$MIN" ]] && bad_syntax=true

if [[ "$bad_syntax" == true ]]; then
    echo 'usage: install-conda-x.sh [ anaconda | miniconda ]'
    exit
fi

echo '' ; echo 'User must have sudoer privileges ...' ; echo ''
sudoer=false
sudo -v &> /dev/null && echo '... sudo privileges activated.' && sudoer=true
[[ "$sudoer" == "false" ]] && echo 'Exiting because sudoer privileges are not available.' && exit

[[ "$CHOSEN" == "$ANA" ]] && NOT_CHOSEN="$MIN" && LATEST=$LATEST_ANA && URL="repo.anaconda.com/archive"
[[ "$CHOSEN" == "$MIN" ]] && NOT_CHOSEN="$ANA" && LATEST=$LATEST_MIN && URL="repo.anaconda.com/miniconda"

# (wisely) gave up on automatically retrieving latest version
## 2022.05: Python version is 3.9
LATEST_ANA="$(</var/local/About_This_Install/anaconda_version)"
LATEST_MIN="$(</var/local/About_This_Install/miniconda_version)"

# Prepare the destination
sudo rm -Rf /usr/local/$CHOSEN
sudo rm -Rf /usr/local/$NOT_CHOSEN

[[ -e /tmp/$CHOSEN ]] && rm -Rf /tmp/$CHOSEN # In case its a re-run
cmd="mkdir /tmp/$CHOSEN ; wget         -O /tmp/$CHOSEN/$LATEST https://$URL/$LATEST ; cd /tmp/$CHOSEN"
eval "$cmd" # do it

# make installer executable
sudo chmod a+x /tmp/$CHOSEN/$LATEST

# install in "-b" batch mode at "-p" path
sudo /tmp/$CHOSEN/$LATEST -b -p /usr/local/$CHOSEN

# Add to default enviroment path so that all users can find it
if [[ ! "$PATH" == *"/usr/local/$CHOSEN"* ]]; then # not in PATH
    echo 'Adding '$CHOSEN' to PATH in /etc/environment'

    sudo chmod u+w /etc/environment
    [[ -e /tmp/environment ]] && sudo rm -Rf /tmp/environment
    
    # Delete the not-chosen version from the path (if there)
    sudo sed -e 's\/usr/local/'$NOT_CHOSEN'/bin:\\g' /etc/environment > /tmp/environment
    mv /etc/environment /etc/environment_orig_"$(date +%Y%m%d%H%M)"
    
    # Add chosen to path
    sudo sed -e "s\/usr/local/sbin:\/usr/local/"$CHOSEN"/bin:/usr/local/sbin:\g" /tmp/environment > /tmp/environment2
    
    # Execute conda.sh also in noninteractive bash shells
    CONDA_INIT_PATH=/usr/local/$CHOSEN/etc/profile.d/conda.sh
    if [[ ! "$CONDA_INIT_PATH" == *"$BASH_ENV"* ]]; then # dont add if already there
	echo "$CONDA_INIT_PATH was already in BASH_ENV"
    else
	echo "$CONDA_INIT_PATH" >> /tmp/environment2
    fi
    
    # Replace original environment and fix permissions
    sudo mv /tmp/environment2 /etc/environment # Weird permissions issue prevents direct redirect into /etc/environment
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
# If conda command has no path, something went wrong
if [[ "$(which conda)" == "" ]]; then
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

# conda init puts the path to conda in user's ~/.bashrc
conda init bash    # For root user
cd /home
for dir in */; do  # For other users
    user=$(basename $dir)
    if id "$user" >/dev/null 2>&1; then # user exists
	sudo adduser "$user" conda &>/dev/null # Let all users manipulate conda
	cmd="sudo -u $user "$(which conda)" init bash >/dev/null"
	eval "$cmd"
    fi
done
