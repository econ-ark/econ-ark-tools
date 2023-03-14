#!/bin/bash
# Install texlive scheme-basic on ubuntu
# tug.org/texlive/quickinstall.html

sudo echo ''
[[ $# != "0"]] && echo 'Script must be run with root permissions.  Exiting.' && exit

SCRIPT=$(realpath -s "$0")
SCRIPT_DIR="$(dirname "$SCRIPT")"
# SCRIPT_DIR=/usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target/installers

TEXLIVE_INSTALL_NO_CONTEXT_CACHE=1
NOPERLDOC=1

cd "$SCRIPT_DIR"

# Get it
[[ -e install-tl-unx.tar.gz ]] && mv install-tl-unx.tar.gz install-tl-unx.tar.gz_old
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat install-tl-unx.tar.gz | tar xf -
[[ -e install-tl ]] && mv install-tl_old

mv install-tl-20* install-tl # rename latest to default

# Install texlive
cd install-tl
echo "selected_scheme scheme-basic" | tee    install.profile
echo "tlpdbopt_install_docfiles 0"  | tee -a install.profile
echo "tlpdbopt_install_srcfiles 0"  | tee -a install.profile
echo "tlpdbopt_autobackup 0"        | tee -a install.profile
echo "tlpdbopt_sys_bin /usr/bin"    | tee -a install.profile

perl ./install-tl --no-interaction -profile install.profile 

sudo ln -s /usr/local/texlive/20?? /usr/local/texlive/YYYY

# Now install path systemwide by putting in /etc/environment.d
ARCH="$(uname -m)" # x86_64 for intel
code="/usr/local/texlive/YYYY/bin/$ARCH-linux" 
if [[ ! -e /etc/environment.d/texlive ]]; then
    echo 'export PATH="/usr/local/texlive/YYYY/bin/ARCH-linux:$PATH"' > /etc/environment.d/texlive
fi
source /etc/environment.d/texlive

# Add the path to tlmgr
/usr/local/texlive/YYYY/bin/$ARCH-linux/tlmgr path add

cd $SCRIPT_DIR/install-tl-extra

./install-tl_scheme-basic_add.sh
