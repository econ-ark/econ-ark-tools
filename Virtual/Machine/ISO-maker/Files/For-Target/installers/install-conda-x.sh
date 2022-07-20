#!/bin/bash

# Install either miniconda or anaconda

# (wisely) gave up on automatically retrieving latest version
## 2022.05: Python version is 3.9
LATEST_ANA="Anaconda3-2022.05-Linux-x86_64.sh"
LATEST_MIN="Miniconda3-py39_4.12.0-Linux-x86_64.sh"

bad_syntax=false

[[ "$#" -ne 1 ]] && bad_syntax=true

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

cmd="wget         -O /tmp/$CHOSEN/$LATEST https://$URL/$LATEST ; cd /tmp/$CHOSEN"
eval "$cmd" # do it

# Prepare the destination
sudo rm -Rf /usr/local/$CHOSEN
sudo rm -Rf /usr/local/$NOT_CHOSEN

# make installer executable
sudo chmod a+x /tmp/$CHOSEN/$LATEST

# install in "-b" batch mode at "-p" path
sudo /tmp/$CHOSEN/$LATEST -b -p /usr/local/$CHOSEN

# Add to default enviroment path so that all users can find it
source /etc/environment
if [[ ! "$PATH" == *"/usr/local/$CHOSEN"* ]]; then # not in PATH
    echo 'Adding '$CHOSEN' to PATH'
    sudo chmod u+w /etc/environment
    sudo rm -Rf /tmp/environment
    # Delete the not-chosen version from the path (if there)
    sudo sed -e 's\/usr/local/'$NOT_CHOSEN'/bin:\\g' /etc/environment > /tmp/environment
    mv /etc/environment /etc/environment_orig_"$(date +%Y%m%d%H%M)"
    # Add chosen to path
    sudo sed -e "s\/usr/local/sbin:\/usr/local/"$CHOSEN"/bin:/usr/local/sbin:\g" /tmp/environment > /tmp/environment2
    # Execute conda.sh even in noninteractive bash shells
    echo 'BASH_ENV=/etc/profile.d/conda.sh' >> /tmp/environment2
    # Replace original environment and fix permissions
    sudo mv /tmp/environment2 /etc/environment # Weird permissions issue prevents direct redirect into /etc/environment
    sudo chmod u-w /etc/environment* # Restore secure permissions for environment
    source /etc/environment  # Get the new environment
fi

# add /usr/local/$CHOSEN to secure path
[[ ! -e /etc/sudoers.d ]] && sudo mkdir -p /etc/sudoers.d && sudo chmod a+w /etc/sudoers.d
if [[ ! -e /etc/sudoers.d/$CHOSEN ]]; then
    # if the other version was previously active, deactivate it
    [[ -e /etc/sudoers.d/$NOT_CHOSEN ]] && rm -Rf /etc/sudoers.d/$NOT_CHOSEN
    # add this version
    sudo echo 'Defaults secure_path="/usr/local/'$CHOSEN'/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/snap/bin:/bin"' | sudo tee /etc/sudoers.d/$CHOSEN
fi
sudo chmod 555 /etc/sudoers.d # restore proper permissions
sudo groupadd conda # probably already exists; but if not ...
sudo chgrp -R conda /usr/local/$CHOSEN # owned by group conda
sudo chmod g+rw     /usr/local/$CHOSEN # members can modify


# conda init puts the path to conda in user's ~/.bashrc
conda init bash    # For root user
cd /home
for dir in */; do  # For other users
    user=$(basename $dir)
    if id "$user" >/dev/nu.. 2>&1; then # user exists
	sudo adduser "$user" conda # Let all users manipulate conda
	cmd="sudo -u $user "$(which conda)" init bash >/dev/null"
	eval "$cmd"
    fi
done

source ~/.bashrc  # Update environment with new change
=======
[[ "$CHOSEN" == "$ANA" ]] && LATEST="Anaconda=3-2021.11-Linux-x86_64.sh" && URL="repo.continuum.io/archive"
[[ "$CHOSEN" == "$MIN" ]] && LATEST="Miniconda3-py39_4.12.0-Linux-x86_64.sh" && URL="repo.anaconda.com"

# (wisely) gave up on automatically retrieving latest version
# 2021.11: Python version is 3.9
cmd="wget         -O /tmp/$CHOSEN/$LATEST https://$URL/$CHOSEN/$LATEST ; cd /tmp/$CHOSEN"
#cmd="wget --quiet -O /tmp/$CHOSEN/$LATEST $SOURCE/$CHOSEN/$LATEST ; cd /tmp/$CHOSEN"
echo "$cmd" # tell
eval "$cmd" # do

# cmd="sudo rm -Rf /usr/local/$CHOSEN ; chmod a+x /tmp/$CHOSEN/$LATEST ; /tmp/$CHOSEN/$LATEST -b -p /usr/local/$CHOSEN"
# echo "$cmd"
# eval "$cmd"

sudo rm -Rf /usr/local/$CHOSEN
sudo chmod a+x /tmp/$CHOSEN/$LATEST
sudo /tmp/$CHOSEN/$LATEST -b -p /usr/local/$CHOSEN

# Add to default enviroment path so that all users can find it

source /etc/environment
if [[ ! "$PATH" == *"/usr/local/$CHOSEN"* ]]; then
    echo 'Adding '$CHOSEN' to PATH'
    # addToPath="export PATH=/usr/local/$CHOSEN/bin:$PATH"
    # echo "$addToPath"
    # eval "$addToPath"
    sudo chmod u+w /etc/environment
    sudo rm -Rf /tmp/environment
    sudo sed -e "s\/usr/local/sbin:\/usr/local/"$CHOSEN"/bin:/usr/local/sbin:\g" /etc/environment > /tmp/environment
    sudo mv /tmp/environment /etc/environment # Weird permissions issue prevents direct redirect into /etc/environment
    sudo chmod u-w /etc/environment # Restore secure permissions for environment
fi

# Pull in the modified environment
source /etc/environment  # Get the new environment

[[ ! -e /etc/sudoers.d ]] && sudo mkdir -p /etc/sudoers.d && sudo chmod a+w /etc/sudoers.d
if [[ ! -e /etc/sudoers.d/$CHOSEN ]]; then
    sudo echo 'Defaults secure_path="/usr/local/'$CHOSEN'/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/snap/bin:/bin"' | sudo tee /etc/sudoers.d/$CHOSEN
fi
sudo chmod 555 /etc/sudoers.d

# The sudos below are not necessary when this script is originally run
# But they are useful when debugging it because they allow copy and paste
# of text to a non-root shell on a line-by-line basis

sudo conda init
>>>>>>> master

# Because installed as root, files are not executable by non-root users but should be
pushd .
cd /usr/local/$CHOSEN
sudo find . -type f -iname ".sh"  -exec chmod a+x {} \;
sudo find . -type f -iname "..sh" -exec chmod a+x {} \; # Gets csh, zsh, whatever
popd

# Mamba is equivalent to conda but much faster for installs
conda install --yes -c conda-forge mamba

# Add some final common tools
conda install --yes -c conda-forge jupyter_contrib_nbextensions
