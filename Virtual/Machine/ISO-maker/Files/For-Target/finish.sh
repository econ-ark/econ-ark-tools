#!/bin/bash
# start.sh installs GUI then reboots;
# finish.sh automatically starts with newly-installed GUI

# Conditionally enable verbose output 
[[ -e /var/local/status/verbose ]] && set -x && set -v

# Now install own stuff
vncuser="econ-ark"
rdpuser="econ-ark-xrdp"
mypass="kra-noce"

# xrdp user allows a second way to contact machine
sudo /var/local/installers/install-and-configure-xrdp.sh $vncuser |& tee -a /var/local/status/install-and-configure-xrdp.log

# Get info about install
commit_msg="$(cat /var/local/About_This_Install/commit-msg.txt)"
short_hash="$(cat /var/local/About_This_Install/short.git-hash)"
commit_date="$(cat /var/local/About_This_Install/commit_date)"

# Change the name of the host to the date and time of its creation
##  Get existing
default_hostname="$(</etc/hostname)"
default_domain=""

# long hostname is date plus commit hash for econ-ark-tools repo
build_date="$(</var/local/status/build_date.txt)"
build_time="$(</var/local/status/build_time.txt)"

new_hostname="xubark-$commit_date-$commit_hash"
# short hostname: xubark+date of commit
[[ ! -e /var/local/status/verbose ]] && new_hostname="xubark-$commit_date" && echo "$new_hostname" > /var/local/status/new_hostname

if [[ "$default_hostname" == "-" ]]; then # not yet defined
    echo "$new_hostname" > /etc/hostname
    echo "$new_hostname" > /etc/hosts
else # replace the default
    sed -i "s/$default_hostname/$new_hostname/g" /etc/hostname
    sed -i "s/$default_hostname/$new_hostname/g" /etc/hosts
fi

# GitHub command line tools
sudo /var/local/installers/install-gh-cli-tools.sh

# LaTeX - minimum required for reproducing many REMARKs
#sudo apt -y install texlive-latex-recommended texlive-fonts-recommended cm-super latexmkrc s=texlive-latex-extras texlive-science texlive-fonts-extra
# LaTeX - absolute minimum
# sudo apt -y install texlive-base

# perltk is needed for tlmgr gui
sudo apt -y install perl-tk

# Install emacs after TeX so that auctex connections work
sudo /var/local/installers/install-emacs.sh |& tee /var/local/status/install-emacs.log
[[ "$(which emacs)"  != "" ]] && sudo emacs -batch -eval "(setq debug-on-error t)" -l /root/.emacs

# Install Chrome browser
arch="$(uname -m)"
if [[ "$arch" == "x86_64" ]]; then
    /var/local/installers/install-chrome-browser.sh
else
    snap install firefox
fi

# Populate About_This_Install directory with info specific to this run of the installer

## Create the "About This Install" markdown file
cat <<EOF > /var/local/About_This_Install/About_This_Install.md
# Detailed Info About This Installation

This machine (virtual or real) was built using 

https://github.com/econ-ark/econ-ark-tools.git

using scripts in commit $short_hash 
with commit message "$commit_msg"
on date "$commit_date"

Starting at the root of a cloned version of that repo,
you should be able to reproduce the installer with:

    git checkout $short_hash
    cd Virtual/Machine/ISO-maker ; ./create-unattended-iso_Econ-ARK-by-size.sh [ MIN | MAX ]

A copy of the ISO installer that generated this machine should be in the

    /installers

directory.

EOF

# Start the GUI if not already running
[[ "$(pgrep xfce4)" == '' ]] && service lightdm stop && service lightdm start

# Packages present in "live" but not in "legacy" version of server
## https://ubuntuforums.org/showthread.php?t=2443047
sudo apt-get -y install cloud-init console-setup eatmydata gdisk libeatmydata1 

# More useful default tools 
sudo apt -y install build-essential module-assistant parted gparted xsel xclip cifs-utils nautilus exo-utils autocutsel gnome-disk-utility gnome-terminal rpl net-tools network-manager-gnome snap evince nodejs deja-dup whois genisoimage 

cd /var/local
branch_name="$(</var/local/status/git_branch)"
online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/"$branch_name"/Virtual/Machine/ISO-maker"

for user in $vncuser $rdpuser root; do
    /var/local/config/config-user.sh $user
done

# Play nice with Macs (in hopes of being able to monitor it)
sudo apt -y install avahi-daemon avahi-discover avahi-utils libnss-mdns mdns-scan ifupdown

# Start avahi so machine can be found on local network -- happens automatically in ubuntu
mkdir -p /etc/avahi/

cp /var/local/sys_root_dir/etc/avahi/avahi-daemon.conf /etc/avahi

# Enable ssh over avahi
cp /usr/share/doc/avahi-daemon/examples/ssh.service /etc/avahi/services

## The boot process looks for /EFI/BOOT directory and on some machines can use this stuff
if [[ -e /EFI/BOOT ]]; then
    cp /var/local/sys_root_dir/EFI/BOOT/Econ-ARK.disk_label    /EFI/BOOT/.disk_label
    cp /var/local/sys_root_dir/EFI/BOOT/Econ-ARK.disk_label_2x /EFI/BOOT/.disk_label2x
    echo 'Econ-ARK'    >                 /EFI/BOOT/.disk_label_contentDetails
fi

cd /var/local/status
size="MAX" # Default to max, unless there is a file named Size-To-Make-Is-MIN
[[ -e /var/local/status/Size-To-Make-Is-MIN ]] && size="MIN"

isoSize="$size"
welcome="# Welcome to the Econ-ARK Machine XUBUNTARK-$size, build "
welcome+="$(cat /var/local/About_This_Install/short.git-hash)"

cat <<EOF > XUBUNTARK.md
$welcome


This machine contains all the software necessary to use all parts of the
Econ-ARK toolkit.

EOF

# bring system up to date
sudo apt -y update && sudo apt -y upgrade

# Install either minimal or maximal system
if [[ "$size" == "MIN" ]]; then
    which_conda=miniconda
else
    which_conda=anaconda
fi

/var/local/installers/install-conda-x.sh $which_conda |& tee /var/local/status/install-conda-x.log
/var/local/config/config-conda.sh  $which_conda |& tee /var/local/status/config-conda.log

source /etc/environment 
source ~/.bashrc
conda activate base
conda install --yes -c conda-forge nbval
conda install --yes -c conda-forge jupyterlab # jupyter notebook is no longer maintained
conda install --yes -c conda-forge pytest
conda install --yes -c conda-forge pytest-xdist
conda install --yes -c conda-forge nbval     # use pytest on notebooks
pip install econ-ark 

if [[ "$which_conda" == "anaconda" ]]; then    
    sudo chmod +x /var/local/finish-MAX-Extras.sh
    sudo /var/local/finish-MAX-Extras.sh
    cd /var/local/status
    echo '' >> XUBUNTARK.md
    echo 'In addition, it contains a rich suite of other software (like LaTeX) widely ' >> XUBUNTARK.md
    echo 'used in scientific computing, including full installations of Anaconda, '     >> XUBUNTARK.md
    echo 'scipy, quantecon, and more.' >> XUBUNTARK.md
    echo '' >> XUBUNTARK.md
fi


sudo apt -y install python-is-python3

# elpy is for syntax checking in emacs
pip install elpy

# Now that elpy has been installed, rerun the emacs setup to connect to it
# Run in batch mode to setup everything
emacs -batch --eval "(setq debug-on-error t)" -l     /home/$vncuser/.emacs 2>&1 |& tee -a /var/local/status/install-emacs.log

cat /var/local/About_This_Install/XUBUNTARK-body.md >> /var/local/status/XUBUNTARK.md

# 20220602: For some reason jinja2 version obained by pip install is out of date
pip install jinja2

# Configure jupyter notebook tools

sudo apt -y install nodejs
sudo jupyter contrib nbextension install
sudo jupyter nbextension enable codefolding/main
sudo jupyter nbextension enable codefolding/edit
sudo jupyter nbextension enable toc2/main
sudo jupyter nbextension enable collapsible_headings/main
#curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo jupyter labextension install jupyterlab-jupytext

# Install systemwide copy of nbreproduce
pip install --upgrade nbreproduce

# Install user-owned copies of useful repos
# Download and extract HARK, REMARK, DemARK, econ-ark-tools from GitHub

# Allow reading of MacOS HFS+ files
sudo apt -y install hfsplus hfsutils hfsprogs

# # Prepare partition for reFind boot manager in MacOS
# hfsplusLabels="$(sudo sfdisk --list --output Device,Sectors,Size,Type,Attrs,Name | grep "HFS+" | awk '{print $1}')"

sudo apt-get update && sudo apt-get upgrade
sudo apt-get install unattended-upgrades

sudo mkdir -p /etc/apt/apt.conf.d
[[ -e /etc/apt/apt.conf.d/20auto-upgrades ]] && sudo mv /etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades_orig
sudo cp /var/local/sys_root_dir/etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades 

# Restore printer services (disabled earlier because sometimes cause hang of boot)
sudo systemctl enable cups-browsed.service 

# Meld is a good file/folder diff tool
sudo apt -y install meld

# Kill tail monitor if it is running
tail_monitor="$(pgrep tail | grep -v pgrep)"
[[ ! -z "$tail_monitor" ]] && sudo kill "$tail_monitor"

# Install timeshift backup tool
sudo /var/local/installers/install-timeshift.sh
sudo /var/local/config/config-timeshift-backups.sh

## Create "O"n-demand backup
backup_time="$(date +%Y%m%d%H%M)"
msg="Initial backup of Econ-ARK machine $backup_time"
sudo timeshift --scripted --yes --create --comments "$msg" 

# Upper right edge of menu bar
sudo apt -y install indicator-application

sudo chmod -Rf a+rw /var/local/status

sudo apt -y purge popularity-contest
sudo apt -y autoremove # Remove unused packages

# GUI software store was removed in purge of gnome*
sudo apt -y install gnome-software

# Signal that we've finished software install
touch /var/local/status/finished-software-install.flag 

# Create locate index of created machine
sudo apt -y install mlocate

sudo reboot
