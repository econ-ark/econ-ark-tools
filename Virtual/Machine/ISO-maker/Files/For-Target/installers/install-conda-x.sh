#!/bin/bash

bad=false

[[ "$#" -ne 1 ]] && bad=true

# In case they used capitals
CHOSEN=$(echo $1 | tr '[:upper:]' '[:lower:]')

ANA='anaconda' && MIN='miniconda'

echo $CHOSEN
[[ "$CHOSEN" != "$ANA" ]] && [[ "$CHOSEN" != "$MIN" ]] && bad=true

if [[ "$bad" == true ]]; then
    echo 'usage: install-conda-x.sh [ anaconda | miniconda ]'
    exit
fi

# Put $CHOSEN in /tmp directory
[[ -e /tmp/$CHOSEN ]] && sudo rm -Rf /tmp/$CHOSEN # delete any prior install
mkdir /tmp/$CHOSEN ; cd /tmp/$CHOSEN

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
/tmp/$CHOSEN/$LATEST -b -p /usr/local/$CHOSEN

# Add to default enviroment path so that all users can find it
addToPath="export PATH=/usr/local/"
addToPath+="$CHOSEN"
addToPath+="/bin:$PATH"
echo "$addToPath"
eval "$addToPath"
# sudo chmod u+w /etc/environment
# sudo rm -Rf /tmp/environment
# echo sudo sed -e "s\/usr/local/sbin:\/usr/local/"$CHOSEN"/bin:/usr/local/sbin:\g" /etc/environment 
# sudo sed -e "s\/usr/local/sbin:\/usr/local/"$CHOSEN"/bin:/usr/local/sbin:\g" /etc/environment > /tmp/environment

# eliminate any duplicates which may exist if the script has been run more than once
#sudo sed -e "s\/usr/local/$CHOSEN/bin:/usr/local/$CHOSEN/bin\/usr/local/$CHOSEN/bin\g" /tmp/environment > /tmp/environment2

sudo mv /tmp/environment /etc/environment # Weird permissions issue prevents direct redirect into /etc/environment
sudo chmod u-w /etc/environment # Restore secure permissions for environment

if [ ! -e /etc/sudoers.d/$CHOSEN ]; then # Modify secure path so that commands will work with sudo
    sudo mkdir -p /etc/sudoers.d
    sudo echo 'Defaults secure_path="/usr/local/'$CHOSEN'/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/snap/bin:/bin"' | sudo tee /etc/sudoers.d/$CHOSEN
fi

# Pull in the modified environment
source /etc/environment  # Get the new environment

# The sudos below are not necessary when this script is originally run
# But they are useful when debugging it because they allow copy and paste
# of text to a non-root shell on a line-by-line basis

sudo conda init

# Because installed as root, files are not executable by non-root users but should be
pushd .
cd /usr/local/$CHOSEN
sudo find . -type f -iname ".sh"  -exec chmod a+x {} \;
sudo find . -type f -iname "..sh" -exec chmod a+x {} \; # Gets csh, zsh, whatever
popd

# sudo conda install --yes -c conda-forge mamba
sudo conda activate base

# Add some final common tools
sudo conda install --yes -c anaconda scipy
sudo conda install --yes -c anaconda pyopengl # Otherwise you get an errmsg "Segmentation fault (core dumped)" on some Ubuntu machines
sudo conda install --yes -c conda-forge jupyter_contrib_nbextensions
