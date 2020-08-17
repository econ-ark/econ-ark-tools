#!/bin/bash
# Set username
set -x
set -v

online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker"
# The cups service sometimes gets stuck; stop it before that happens
sudo systemctl stop cups-browsed.service 
sudo systemctl disable cups-browsed.service
# Update everything 
sudo apt -y update && sudo apt -y upgrade

sudo apt-get -y install firmware-b43-installer # Possibly useful for macs; a bit obscure, but kernel recommends it

#
# Xubuntu installs xfce-screensaver; remove the default one
# It's confusing to have two screensavers running:
#   You think you have changed the settings but then the other one's
#   settings are not changed
# For xfce4-screensaver, unable to find a way programmatically to change
# so must change them by hand
sudo apt -y remove  xscreensaver

# Play nice with Macs ASAP (in hopes of being able to monitor it)


sudo apt -y install avahi-daemon avahi-discover avahi-utils libnss-mdns mdns-scan

# Start avahi so it can be found on local network -- happens automatically in ubuntu

mkdir -p /etc/avahi/
curl -L -o /etc/avahi $online/etc/avahi/avahi-daemon.conf

avahi-daemon --reload

refindFile="refind-install-MacOS.sh"

curl -L -o /var/local/grub-menu.sh $online/grub-menu.sh 
curl -L -o /var/local/Econ-ARK.VolumeIcon.icns $online/Disk/Icons/Econ-ARK.VolumeIcon.icns
curl -L -o /var/local/Econ-ARK.disk_label      $online/Disk/Labels/Econ-ARK.disklabel    
curl -L -o /var/local/Econ-ARK.disk_label_2x   $online/Disk/Labels/Econ-ARK.disklabel_2x 
curl -L -o /var/local/$refindFile $online/$refindFile
chmod +x /var/local/$refindFile
sudo apt -y install tigervnc-scraping-server


# https://askubuntu.com/questions/328240/assign-vnc-password-using-script
myuser="econ-ark"
mypass="kra-noce"
echo "$mypass" >  /tmp/vncpasswd # First is the read-write password
echo "$myuser" >> /tmp/vncpasswd # Next  is the read-only  password (useful for sharing screen with students)

[[ -e /home/$myuser/.vnc ]] && rm -Rf /home/$myuser/.vnc  # If a previous version exists, delete it
sudo mkdir -p /home/$myuser/.vnc


# set defaults
default_hostname="$(hostname)"
default_domain=""

# define download function
# courtesy of http://fitnr.com/showing-file-download-progress-using-wget.html
download()
{
    local url=$1
#    echo -n "    "
    wget --progress=dot $url 2>&1 | grep --line-buffered "%" | \
        sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
#    echo -ne "\b\b\b\b"
#    echo " DONE"
}

tmp="/tmp"

# Change the name of the host to the date and time of its creation
datetime="$(date +%Y%m%d%H%S)"
sed -i "s/xubuntu/$datetime/g" /etc/hostname
sed -i "s/xubuntu/$datetime/g" /etc/hosts

cd /home/"$myuser"

touch /home/econ-ark/.bash_aliases # in case it doesn't exist yet
# Install anaconda3 for all users 
bashadd=/home/"$myuser"/.bash_aliases
[[ -e "$bashadd" ]] && mv "$bashadd" "$bashadd-orig"
touch "$bashadd"
# Adapted from http://askubuntu.com/questions/505919/how-to-install-anaconda-on-ubuntu
cat /var/local/bash_aliases-add >> "$bashadd"


# Make ~/.bash_aliases be owned by "$myuser" instead of root
chmod a+x "$bashadd"
chown $myuser:$myuser "$bashadd" 


# Security (needed for emacs)
sudo apt -y install ca-certificates


# Create .emacs.d directory with proper permissions -- avoids annoying startup warning msg
cd    /home/$myuser
echo "downloading .emacs file"

download "https://raw.githubusercontent.com/ccarrollATjhuecon/Methods/master/Tools/Config/tool/emacs/dot/emacs-ubuntu-virtualbox"

cp emacs-ubuntu-virtualbox /home/econ-ark/.emacs
cp emacs-ubuntu-virtualbox /root/.emacs
chown "root:root" /root/.emacs

mkdir -p /EFI/BOOT/
cp /var/local/Econ-ARK.disk_label    /EFI/BOOT/.disk_label
cp /var/local/Econ-ARK.disk_label_2x /EFI/BOOT/.disk_label2x
echo 'Econ-ARK'    >                 /EFI/BOOT/.disk_label_contentDetails

# Install emacs
chmod a+rwx /home/$myuser/.emacs
chown "$myuser:$myuser" /home/$myuser/.emacs

rm -f emacs-ubuntu-virtualbox

[[ ! -e /home/$myuser/.emacs.d ]] && sudo mkdir /home/$myuser/.emacs.d && sudo chown "$myuser:$myuser" /home/$myuser/.emacs.d
[[ ! -e /root/.emacs.d ]] && mkdir /root/.emacs.d

chmod a+rw /home/$myuser/.emacs.d 

# Remove the linux automatically created directories like "Music" and "Pictures"
# Leave only required directories Downloads and Desktop
cd /home/$myuser

for d in ./*/; do
    if [[ ! "$d" == "./Downloads/" ]] && [[ ! "$d" == "./Desktop/" ]] && [[ ! "$d" == "./snap/" ]]; then
	rm -Rf "$d"
    fi
done

sudo touch /etc/cron.hourly/jobs.deny
sudo chmod a+rw /etc/cron.hourly/jobs.deny
echo 0anacron > /etc/cron.hourly/jobs.deny # Anacron kept killing first boot



sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt -y install software-properties-common python3 python3-pip python-pytest
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 10
sudo pip install python-pytest
sudo -i -u econ-ark python-pytest
sudo pip install nbval
# Get default packages for Econ-ARK machine
sudo apt -y install curl git bash-completion cifs-utils openssh-server xclip xsel gpg
# Create a public key for security purposes
ssh-keygen -t rsa -b 4096 -q -N "" -C $myuser@XUBUNTU -f /home/$myuser/.ssh
# Set up security for emacs package downloading 
sudo apt -y install emacs
sudo -i -u  econ-ark mkdir -p /home/econ-ark/.emacs.d/elpa
sudo -i -u  econ-ark mkdir -p /home/econ-ark/.emacs.d/elpa/gnupg
sudo chown econ-ark:econ-ark /home/econ-ark/.emacs
sudo chown econ-ark:econ-ark -Rf /home/econ-ark/.emacs.d
sudo -i -u  econ-ark gpg --list-keys 
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa       --list-keys
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa/gnupg --list-keys
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa       --receive-keys 066DAFCB81E42C40
sudo -i -u  econ-ark gpg --homedir /home/econ-ark/.emacs.d/elpa/gnupg --receive-keys 066DAFCB81E42C40
sudo -i -u  econ-ark emacs -batch -l     /home/econ-ark/.emacs 
sudo emacs -batch -l /root/.emacs 

pip install econ-ark # pip install econ-ark
arkHome=/usr/local/share/data/GitHub/econ-ark
mkdir -p "$arkHome"
cd "$arkHome"
git clone https://github.com/econ-ark/REMARK.git
git clone https://github.com/econ-ark/HARK.git
git clone https://github.com/econ-ark/DemARK.git
git clone https://github.com/econ-ark/econ-ark-tools.git
chmod a+rw -Rf /usr/local/share/data/GitHub/econ-ark

echo 'This is your local, personal copy of HARK; it is also installed systemwide.  '    >  HARK-README.md
echo 'Local mods will not affect systemwide, unless you change the default source via:' >> HARK-README.md
echo "   cd $arkHOME ;  pip install -e setup.py "  >> HARK-README.md
echo '' >> HARK-README.md
echo '(You can switch back to the systemwide version using pip install econ-ark)' >> HARK-README.md
echo 'To test whether everything works, in the root directory type:.  '    >  HARK-README.md
echo 'pytest '    >  HARK-README.md


echo 'This is your local, personal copy of DemARK, which you can modify.  '    >  DemARK-README.md
echo 'To test whether everything works, in the root directory type:.  '    >  DemARK-README.md
echo 'cd notebooks ; pytest --nbval-lax *.ipynb  '    >  DemARK-README.md

echo 'This is your local, personal copy of REMARK, which you can modify.  '    >  REMARK-README.md

# Don't need to install jupyter or jupyter lab because they come with Anaconda which is installed below


# Get the full contents of the REMARK directory

cd /usr/local/share/data/GitHub/econ-ark/REMARK
git submodule update --init --recursive --remote
git pull

sudo -u econ-ark pip install jupyter_contrib_nbextensions
sudo -u econ-ark jupyter contrib nbextension install --user
# Extra nbextensions for MAX
sudo -u econ-ark jupyter nbextension enable codefolding/main
sudo -u econ-ark jupyter nbextension enable codefolding/edit
sudo -u econ-ark jupyter nbextension enable toc2/main
sudo -u econ-ark jupyter nbextension enable collapsible_headings/main
cd /usr/local/share/data/GitHub/econ-ark/REMARK/binder ; pip install -r requirements.txt
cd /usr/local/share/data/GitHub/econ-ark/DemARK/binder ; pip install -r requirements.txt


sudo apt -y install build-essential module-assistant parted gparted
sudo apt -y install curl git bash-completion xsel cifs-utils openssh-server nautilus-share xclip gpg

mkdir -p /home/econ-ark/GitHub ; ln -s /usr/local/share/data/GitHub/econ-ark /home/econ-ark/GitHub/econ-ark
chown econ-ark:econ-ark /home/econ-ark/GitHub
chown -Rf econ-ark:econ-ark /usr/local/share/data/GitHub/econ-ark # Make it be owned by econ-ark user 

sudo apt -y install hfsplus hfsutils hfsprogs


# Prepare partition for reFind boot in MacOS
hfsplusLabels="$(sudo sfdisk --list --output Device,Sectors,Size,Type,Attrs,Name | grep "HFS+" | awk '{print $1}')"

# If you want to pop up an informative window at this stage, you must set the environment variables below:
# export DISPLAY=:0.0
# export XAUTHORITY=/home/econ-ark/.Xauthority
# export SESSION_MANAGER="$(cat /tmp/SM)"
# xhost SI:localhost:root

echo "hfsplusLabels=$hfsplusLabels"
if [[ "$hfsplusLabels" != "" ]]; then
    cmd="mkfs.hfsplus -v 'refind-HFS' $hfsplusLabels"
    echo "cmd=$cmd"
    sudo mkfs.hfsplus -v 'refind-HFS' "$hfsplusLabels"
    sudo mkdir /tmp/refind-HFS && sudo mount -t hfsplus "$hfsplusLabels" /tmp/refind-HFS
    sudo cp /home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/refind-install-MacOS.sh /tmp/refind-HFS
    sudo cp /var/local/Econ-ARK.VolumeIcon.icns /tmp/refind-HFS/.VolumeIcon.icns
    sudo cp /var/local/Econ-ARK.VolumeIcon.icns /.VolumeIcon.icns
    sudo chmod a+x /tmp/refind-HFS/*.sh
    sudo curl -L -o /tmp/refind-HFS https://github.com/econ-ark/econ-ark-tools/blob/master/Virtual/Machine/ISO-maker/Disk/Icons/os_refit.icns /tmp/refind-HFS/.VolumeIcon.icns
    # hfsplusLabels="$(sudo sfdisk --list --output Device,Sectors,Size,Type,Attrs,Name | grep "HFS+" | awk '{print $1}')"
    # sudo apt-get --assume-no install refind # If they might be booting from MacOS or Ubuntu, make refind the base bootloader
    # ESP=$(sudo sfdisk --list | grep EFI | awk '{print $1}')
    # sudo refind-install --usedefault "$ESP"
fi


# If running in VirtualBox, install Guest Additions and add vboxsf to econ-ark groups
[[ "$(which lshw)" ]] && vbox="$(lshw | grep VirtualBox) | grep VirtualBox"  && [[ "$vbox" != "" ]] && sudo apt -y install virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 && sudo adduser econ-ark vboxsf

# Extra packages for MAX
# Put in /tmp directory
[[ -e /tmp/Anaconda ]] && sudo rm -Rf /tmp/Anaconda # delete any prior install
mkdir /tmp/Anaconda ; cd /tmp/Anaconda
CONTREPO=https://repo.continuum.io/archive/
# Stepwise filtering of the html at $CONTREPO
# Get the topmost line that matches our requirements, extract the file name.
ANACONDAURL=$(wget -q -O - $CONTREPO index.html | grep "Anaconda3-" | grep "Linux" | grep "86_64" | head -n 1 | cut -d \" -f 2)
cmd="wget -O /tmp/Anaconda/$ANACONDAURL $CONTREPO$ANACONDAURL ; cd /tmp/Anaconda"
echo "$cmd"
eval "$cmd"

cmd="sudo rm -Rf /usr/local/anaconda3 ; chmod a+x /tmp/Anaconda/$ANACONDAURL ; /tmp/Anaconda/$ANACONDAURL -b -p /usr/local/anaconda3"
echo "$cmd"
eval "$cmd"

# Add to default enviroment path so that everyone can find it
addToPath='export PATH=/usr/local/anaconda3/bin:$PATH'
echo "$addToPath"
eval "$addToPath"
sudo chmod u+w /etc/environment
sudo sed -e 's\/usr/local/sbin:\/usr/local/anaconda3/bin:/usr/local/sbin:\g' /etc/environment > /tmp/environment

sudo apt -y install avahi-daemon avahi-discover avahi-utils libnss-mdns mdns-scan
# eliminate any duplicates which may exist if the script has been run more than once
sudo sed -e 's\/usr/local/anaconda3/bin:/usr/local/anaconda3/bin\/usr/local/anaconda3/bin\g' /tmp/environment > /tmp/environment2

sudo mv /tmp/environment2 /etc/environment # Weird permissions issue prevents direct redirect into /etc/environment
sudo chmod u-w /etc/environment # Restore secure permissions for environment

if [ ! -e /etc/sudoers.d/anaconda3 ]; then # Modify secure path so that anaconda commands will work with sudo
    sudo mkdir -p /etc/sudoers.d
    sudo echo 'Defaults secure_path="/usr/local/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/snap/bin:/bin"' | sudo tee /etc/sudoers.d/anaconda3
fi

source /etc/environment  # Get the new environment

conda update --yes conda
conda update --yes anaconda

# Add some final common tools
conda install --yes -c anaconda scipy
conda install --yes -c anaconda pyopengl # Otherwise you get an error "Segmentation fault (core dumped)" on some Ubuntu machines
conda install --yes -c conda-forge jupyter_contrib_nbextensions

sudo pip install nbval
# Get default packages for Econ-ARK machine
sudo apt -y install curl git bash-completion xsel cifs-utils openssh-server nautilus-share xclip gpg
# Extra packages for MAX
sudo apt -y evince texlive-full quantecon 
# Create a public key for security purposes
sudo -u $myuser ssh-keygen -t rsa -b 4096 -q -N "" -C $myuser@XUBUNTU -f /home/@myuser/.ssh

#Download and extract HARK, REMARK, DemARK from GitHUB repository

conda install --yes -c conda-forge econ-ark # pip install econ-ark
# Extra packages for MAX
# Put in /tmp directory
[[ -e /tmp/Anaconda ]] && sudo rm -Rf /tmp/Anaconda # delete any prior install
mkdir /tmp/Anaconda ; cd /tmp/Anaconda
CONTREPO=https://repo.continuum.io/archive/
# Stepwise filtering of the html at $CONTREPO
# Get the topmost line that matches our requirements, extract the file name.
ANACONDAURL=$(wget -q -O - $CONTREPO index.html | grep "Anaconda3-" | grep "Linux" | grep "86_64" | head -n 1 | cut -d \" -f 2)
cmd="wget -O /tmp/Anaconda/$ANACONDAURL $CONTREPO$ANACONDAURL ; cd /tmp/Anaconda"
echo "$cmd"
eval "$cmd"

cmd="sudo rm -Rf /usr/local/anaconda3 ; chmod a+x /tmp/Anaconda/$ANACONDAURL ; /tmp/Anaconda/$ANACONDAURL -b -p /usr/local/anaconda3"
echo "$cmd"
eval "$cmd"

# Add to default enviroment path so that everyone can find it
addToPath='export PATH=/usr/local/anaconda3/bin:$PATH'
echo "$addToPath"
eval "$addToPath"
sudo chmod u+w /etc/environment
sudo sed -e 's\/usr/local/sbin:\/usr/local/anaconda3/bin:/usr/local/sbin:\g' /etc/environment > /tmp/environment

sudo apt -y install avahi-daemon avahi-discover avahi-utils libnss-mdns mdns-scan
# eliminate any duplicates which may exist if the script has been run more than once
sudo sed -e 's\/usr/local/anaconda3/bin:/usr/local/anaconda3/bin\/usr/local/anaconda3/bin\g' /tmp/environment > /tmp/environment2

sudo mv /tmp/environment2 /etc/environment # Weird permissions issue prevents direct redirect into /etc/environment
sudo chmod u-w /etc/environment # Restore secure permissions for environment

if [ ! -e /etc/sudoers.d/anaconda3 ]; then # Modify secure path so that anaconda commands will work with sudo
    sudo mkdir -p /etc/sudoers.d
    sudo echo 'Defaults secure_path="/usr/local/anaconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/snap/bin:/bin"' | sudo tee /etc/sudoers.d/anaconda3
fi

source /etc/environment  # Get the new environment

conda update --yes conda
conda update --yes anaconda

# Add some final common tools
conda install --yes -c anaconda scipy
conda install --yes -c anaconda pyopengl # Otherwise you get an error "Segmentation fault (core dumped)" on some Ubuntu machines
conda install --yes -c conda-forge jupyter_contrib_nbextensions

sudo pip install nbval
# Get default packages for Econ-ARK machine
# Extra packages for MAX
sudo apt -y evince texlive-full quantecon 
# Create a public key for security purposes
sudo -u $myuser ssh-keygen -t rsa -b 4096 -q -N "" -C $myuser@XUBUNTU -f /home/@myuser/.ssh

#Download and extract HARK, REMARK, DemARK from GitHUB repository

conda install --yes -c conda-forge econ-ark # pip install econ-ark


pushd  .
isoName=ubuntu-20.04-legacy-server-amd64-unattended_econ-ark.iso
echo ''
echo 'Fetching online image of this installer to '
echo "/media/$isoName"

sudo rm "/media/$isoName"
gdown --id "19AL7MsaFkTdFA1Uuh7gE57Ksshle2RRR" --output "/media/$isoName"

popd
reboot 
