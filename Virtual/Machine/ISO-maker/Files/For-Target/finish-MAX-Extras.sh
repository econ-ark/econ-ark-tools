#!/bin/bash
# Add extra stuff that, together, constitutes a well-provisioned
# scientific computing environment. If you have constructed the MIN
# machine, you should be able to upgrade it to this one by running
# ./finish-MAX-Extras.sh

# Presence of 'verbose' triggers bash debugging mode
[[ -e /var/local/status/verbose ]] && set -x && set -v

if [[ "$(which conda)" == "/usr/local/anaconda/bin/conda" ]] ; then # It's already installed
    sudo conda update --yes --all conda    # It's installed, so just update it
    sudo conda update --yes --all anaconda # It's installed, so just update it
else
    /var/local/installers/install-conda-x.sh anaconda
    source ~/.bashrc # get new environment with path to anaconda

    sudo conda install --yes -c conda-forge mamba 
    sudo conda activate base 
    
    # Add some final common tools
    sudo mamba install --yes -c anaconda scipy
    sudo mamba install --yes -c anaconda pyopengl # Otherwise you get an errmsg "Segmentation fault (core dumped)" on some Ubuntu machines

    # Extra packages for MAX
    sudo apt -y install gv perl-tk texlive-full ripgrep fd-find
    sudo apt -y install flatpak gnome-software-plugin-flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak -y install flathub org.gnu.emacs

fi

sudo pip uninstall --yes econ-ark ; sudo conda install --yes -c conda-forge econ-ark # pip install econ-ark

source /etc/environment  # Get the new environment

# Instructions from Anaconda mothership say to install pip stuff
# only after installing all conda stuff

sudo conda install --yes -c conda-forge nbval     # use pytest on notebooks
sudo pip install quantecon

# Get docker 
sudo apt -y remove  man-db # As of 2020-08-16, install of docker freezes at man-db step
sudo apt -y install docker 

arkHome=/usr/local/share/data/GitHub/econ-ark
mkdir -p "$arkHome"
sudo chown econ-ark:econ-ark $arkHome

cd "$arkHome"

for repo in REMARK HARK DemARK; do
    [[ -e "$repo" ]] && sudo rm -Rf "$repo" 
    sudo -u econ-ark git clone --depth 1 https://github.com/econ-ark/$repo
    # Make it all owned by the econ-ark user -- including invisible files like .git
    # Install all requirements
    [[ -e $repo/requirements.txt ]] && sudo pip install -r $repo/requirements.txt
    [[ -e $repo/binder/requirements.txt ]] && sudo pip install -r $repo/binder/requirements.txt
done

echo 'This is your local, personal copy of HARK; it is also installed systemwide.  '      >  HARK-README.md
echo 'Local mods will not affect systemwide, unless you change the default source via:'   >> HARK-README.md
echo "   cd $arkHOME ;  pip install -e setup.py "                                         >> HARK-README.md
echo '' >> HARK-README.md
echo '(You can switch back to the systemwide version using pip install econ-ark)'         >> HARK-README.md
echo 'To test whether everything works, in the root directory type:.  '                   >> HARK-README.md
echo 'pytest '                                                                            >> HARK-README.md

echo 'This is your local, personal copy of DemARK, which you can modify.  '    >  DemARK-README.md
echo 'To test whether everything works, in the root directory type:.  '       >>  DemARK-README.md
echo 'cd notebooks ; pytest --nbval-lax --ignore=Chinese-Growth.ipynb *.ipynb  '                            >>  DemARK-README.md

echo 'This is your local, personal copy of REMARK, which you can modify.  '    >  REMARK-README.md

# Run the automated tests to make sure everything installed properly
cd /usr/local/share/data/GitHub/econ-ark/HARK

sudo conda install --yes -c anaconda pytest
pytest 

cd /usr/local/share/data/GitHub/econ-ark/DemARK/notebooks
# 20220508: Chinese-Growth is very slow
pytest --nbval-lax --ignore-glob='Chinese*.*' --nbval-cell-timeout=120 *.ipynb

