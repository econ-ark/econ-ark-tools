#!/bin/bash
# Add extra stuff that, together, constitutes a well-provisioned scientific computing environment
# If you have constructed the MIN machine, you should be able to upgrade it to this one
# by running ./finish-MAX-Extras.sh

set -x # Debug
set -v # Debug

if [[ "$(which conda)" == "/usr/local/anaconda3/bin/conda" ]] ; then # It's already installed
    conda update --yes --all conda    # It's installed, so just update it
    conda update --yes --all anaconda # It's installed, so just update it
else
    # Put Anaconda in /tmp directory
    [[ -e /tmp/Anaconda ]] && sudo rm -Rf /tmp/Anaconda # delete any prior install
    mkdir /tmp/Anaconda ; cd /tmp/Anaconda
    CONTREPO=https://repo.continuum.io/archive/
    # Stepwise filtering of the html at $CONTREPO
    # Get the topmost line that matches our requirements, extract the file name
    # (this gives us the latest stable version)
    ANACONDAURL=$(wget -q -O - $CONTREPO index.html | grep "Anaconda3-" | grep "Linux" | grep "86_64" | head -n 1 | cut -d \" -f 2)
    cmd="wget -O /tmp/Anaconda/$ANACONDAURL $CONTREPO$ANACONDAURL ; cd /tmp/Anaconda"
    echo "$cmd" # tell
    eval "$cmd" # do 

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

    # Add some final common tools
    conda install --yes -c anaconda scipy
    conda install --yes -c anaconda pyopengl # Otherwise you get an error "Segmentation fault (core dumped)" on some Ubuntu machines
    conda install --yes -c conda-forge jupyter_contrib_nbextensions

    sudo pip install nbval
    # Get default packages for Econ-ARK machine
    sudo apt -y install cifs-utils nautilus-share
    # Extra packages for MAX
    sudo apt -y install evince texlive-full
    pip install quantecon
    # Create a public key for security purposes

    #Download and extract HARK, REMARK, DemARK from GitHUB repository
fi

conda install --yes -c conda-forge econ-ark # pip install econ-ark

source /etc/environment  # Get the new environment


# Get docker 
sudo apt -y remove  man-db # As of 2020-08-16, install of docker freezes at man-db step
sudo apt -y install docker 
