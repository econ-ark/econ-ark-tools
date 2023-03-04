#!/bin/bash
# Add extra stuff that, together, constitutes a well-provisioned
# scientific computing environment. If you have constructed the MIN
# machine, you should be able to upgrade it to this one by running
# ./finish-MAX-Extras.sh; but the better way to do it is
# 1. In the directory /var/local/status,
#    rename Size-To-Make-Is-MIN to Size-To-Make-Is-MAX
# 2. sudo /var/local/finish.sh

# Presence of 'verbose' triggers bash debugging mode
[[ -e /var/local/status/verbose ]] && set -x && set -v

source /etc/environment  # Get the new environment

# Instructions from Anaconda mothership say to install pip stuff
# only after installing all conda stuff

conda install --yes -c conda-forge nbval     # use pytest on notebooks
pip install quantecon

# Get docker 
sudo apt -y remove  man-db # As of 2020-08-16, install of docker freezes at man-db step
sudo apt -y install docker 

arkHome=/usr/local/share/data/GitHub/econ-ark
mkdir -p "$arkHome"
sudo chown -Rf econ-ark:econ-ark $arkHome

cd "$arkHome"

for repo in REMARK HARK DemARK; do
    [[ -e "$repo" ]] && sudo rm -Rf "$repo" 
    sudo -u econ-ark git clone --depth 1 https://github.com/econ-ark/$repo
    # Install all requirements
    [[ -e $repo/requirements.txt ]] && pip install -r $repo/requirements.txt
    [[ -e $repo/binder/apt.txt ]] && xargs sudo apt -y install < $repo/binder/apt.txt
    [[ -e $repo/binder/requirements.txt ]] && pip install -r $repo/binder/requirements.txt
done

echo 'This is your local, personal copy of HARK; it is also installed systemwide.  '      >  HARK-README.md
echo 'Local mods will not affect systemwide, unless you change the default source via:'   >> HARK-README.md
echo "   cd $arkHOME ;  pip install -e setup.py "                                 >> HARK-README.md
echo '' >> HARK-README.md
echo '(You can switch back to the systemwide version using pip install econ-ark)' >> HARK-README.md
echo 'To test whether everything works, in the root directory type:.  '                   >> HARK-README.md
echo 'pytest '                                                                            >> HARK-README.md

echo 'This is your local, personal copy of DemARK, which you can modify.  '    >  DemARK-README.md
echo 'To test whether everything works, in the root directory type:.  '       >>  DemARK-README.md
echo 'cd notebooks ; pytest --nbval-lax --ignore=Chinese-Growth.ipynb *.ipynb  '                            >>  DemARK-README.md

echo 'This is your local, personal copy of REMARK, which you can modify.  '    >  REMARK-README.md

# Run the automated tests to make sure everything installed properly
cd /usr/local/share/data/GitHub/econ-ark/HARK

conda install --yes -c anaconda pytest
pytest -n auto

cd /usr/local/share/data/GitHub/econ-ark/DemARK/notebooks
# 20220508: Chinese-Growth is very slow
# pytest --nbval-lax --ignore-glob='Chinese*.*' --nbval-cell-timeout=120 *.ipynb
pytest -n auto --nbval-lax --ignore-glob='Chinese*.*' --nbval-cell-timeout=120 *.ipynb


#

# TeXLive installation takes several hours
sudo apt -y install texlive-full
