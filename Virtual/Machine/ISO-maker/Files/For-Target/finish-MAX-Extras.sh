#!/bin/bash
# Add extra stuff that, together, constitutes a well-provisioned
# scientific computing environment. If you have constructed the MIN
# machine, you should be able to upgrade it to this one by running
# ./finish-MAX-Extras.sh

set -x # Debug
set -v # Debug

if [[ "$(which conda)" == "/usr/local/anaconda3/bin/conda" ]] ; then # It's already installed
    sudo conda update --yes --all conda    # It's installed, so just update it
    sudo conda update --yes --all anaconda # It's installed, so just update it
else
    # Put Anaconda in /tmp directory
    [[ -e /tmp/Anaconda ]] && sudo rm -Rf /tmp/Anaconda # delete any prior install
    mkdir /tmp/Anaconda ; cd /tmp/Anaconda
    CONTREPO=https://repo.continuum.io/archive
    LATEST="Anaconda3-2021.11-Linux-x86_64.sh" # Gave up on automatically retrieving latest version
    # 2021.11: Python version is 3.9
    cmd="wget --quiet -O /tmp/Anaconda/$LATEST $CONTREPO/$LATEST ; cd /tmp/Anaconda"
    echo "$cmd" # tell
    eval "$cmd" # do 

    cmd="sudo rm -Rf /usr/local/anaconda3 ; chmod a+x /tmp/Anaconda/$LATEST ; /tmp/Anaconda/$LATEST -b -p /usr/local/anaconda3"
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

    # The sudos below are not necessary when this script is originally run
    # But they are useful when debugging it because they allow copy and paste
    # of text to a non-root shell on a line-by-line basis

    sudo conda init

    # Because installed as root, files are not executable by non-root users but should be
    pushd .
    cd /usr/local/anaconda3 
    sudo find . -type f -iname ".sh"  -exec chmod a+x {} \;
    sudo find . -type f -iname "..sh" -exec chmod a+x {} \; # Gets csh, zsh, whatever
    popd
    
    sudo conda install --yes -c conda-forge mamba 
    sudo conda activate base 
#    sudo mamba create --yes --name base_py38 python=3.8 anaconda
#    sudo conda activate base_py38
#    sudo conda install --yes -c conda-forge mamba
    # As of 20210202 py39 is not ready yet
#    sudo conda create --yes --name base_py39 python=3.9 anaconda
#    sudo conda activate base_py39
#    sudo conda install --yes -c conda-forge mamba
    sudo mamba update anaconda
    
    # Add some final common tools
    sudo mamba install --yes -c anaconda scipy
    sudo mamba install --yes -c anaconda pyopengl # Otherwise you get an error "Segmentation fault (core dumped)" on some Ubuntu machines
    sudo mamba install --yes -c conda-forge jupyter_contrib_nbextensions
    # Make sure commands are executable by regular users

    sudo tasksel install xubuntu-desktop
    sudo mamba install --yes -c conda-forge gh  # GitHub command line tools
    
    # Get default packages for Econ-ARK machine
    sudo apt -y install cifs-utils nautilus-share
    # Extra packages for MAX
    sudo apt -y install gv evince perl-tk texlive-full ripgrep fd-find
    sudo apt -y install  flatpak gnome-software-plugin-flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak -y install flathub org.gnu.emacs

    # Backup tools
    sudo apt -y install deja-dup
    sudo apt -y install timeshift
    
    # Configure latexmkrc: https://mg.readthedocs.io/latexmk.html
    ltxmkrc=/home/econ-ark/.latekmkrc
    echo "'"'$dvi_previewer = start xdvi -watchfile 1.5'"';" > "$ltxmkrc"
    echo "'"'$ps_previewer = start gv --watch'"';" >> "$ltxmkrc"
    echo "'"'$pdf_previewer = start evince'"';" >> "$ltxmkrc"
    sudo apt -y install /var/local/zoom_amd64.deb
fi

    sudo pip uninstall --yes econ-ark ; sudo conda install --yes -c conda-forge econ-ark # pip install econ-ark

source /etc/environment  # Get the new environment

# Instructions from Anaconda mothership say to install pip stuff
# only after installing all conda stuff

sudo pip install nbval
sudo pip install quantecon

# Get docker 
sudo apt -y remove  man-db # As of 2020-08-16, install of docker freezes at man-db step
sudo apt -y install docker 

