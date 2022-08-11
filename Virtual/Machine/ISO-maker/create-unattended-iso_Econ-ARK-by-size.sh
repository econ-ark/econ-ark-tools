#!/bin/bash
# Adapted from netson github create-unattended/create-unattended-iso.sh
# Run this with a command like:
# ./create-unattended-iso_Econ-ARK-by-size.sh MIN
# (or MAX to create the richly endowed machine)

if [ "$TERM" == "dumb" ]; then
    echo ''
    echo 'This script should be run from a smart terminal.'
    echo 'But $TERM='"$TERM"' probably because running in emacs shell'
    echo ''
    echo 'In emacs:'
    echo '    M-x "'"term"'" will launch a smart terminal'
    echo '    C-x o will switch to the terminal buffer'
    echo '    C-c o will switch back out of the terminal buffer'
    echo ''
    exit 1
fi

# 
if [ "$#" -gt 1 ]; then
    echo "Wrong number of arguments:"
    echo "usage: ${0##*/} [Internal-Allow | Internal-Prohibit]"
    exit 1
else
    if [[ "$#" == 0 ]]; then
	Internal="Internal-Prohibit"
    else
	if ( [ ! "$1" == "Internal-Allow" ] && [ ! "$1" == "Internal-Prohibit" ] ); then
	    echo "usage: ${0##*/} [Internal-Allow | Internal-Prohibit]"
	    exit 2
	else
	    Internal="$1"
	fi
    fi
fi

modprobe_blacklist=""
[[ "$Internal" == "Internal-Prohibit" ]] && modprobe_blacklist="modprobe.blacklist=ahci"

pathToScript=$(dirname `realpath "$0"`)
size="MIN" # size=MIN; pathToScript=/usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target

echo '' ; echo 'User must have sudoer privileges ...' ; echo ''
sudoer=false
sudo -v &> /dev/null && echo '... sudo privileges activated.' && sudoer=true
[[ "$sudoer" == "false" ]] && echo 'Exiting because no valid sudoer privileges.' && exit

version="base" # or "full" for debugging (too-many-options) on the grub menu

echo "size_to_build=$size"

# Get the latest git commit hash and message
short_hash="$(git rev-parse --short HEAD)"
commit_date="$(git show -s --format=%cd --date=format:'%Y%m%d-%H%M')"
msg="$(git log -1 --pretty=%B | tr ' ' '_' | tr '/' '-')"
dirExtra="Files/For-Target"
ATI="About_This_Install"
DIR="$pathToScript/$dirExtra"

# Keep track locally of what was the most recently built version
[[ -e "/var/local/status/Size-To-Make-Is-MIN" ]] && rm    "/var/local/status/Size-To-Make-Is-MIN"
[[ -e "/var/local/status/Size-To-Make-Is-MAX" ]] && rm    "/var/local/status/Size-To-Make-Is-MAX"
touch "/var/local/status/Size-To-Make-Is-$size"

# Names/paths of local and remote files
ForTarget="Files/For-Target"
ForISO="Files/For-ISO"

# Allow for branches to test alternative builds
git_branch="$(git symbolic-ref HEAD 2>/dev/null)" ; git_branch=${git_branch##refs/heads/}
echo $git_branch > $ForTarget/status/git_branch # store the name of the current branch
online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/$git_branch/Virtual/Machine/ISO-maker"
startFile="start.sh"
finishFile="finish.sh"
finishMAX="finish-MAX-Extras.sh"
seed_file="econ-ark.seed"
rclocal_file="rc.local"

iso_from="/media/sf_VirtualBox"                          # where to find the original ISO
iso_done="/media/sf_VirtualBox/ISO-made/econ-ark-tools"  # where to store the final iso file - shared with host machine

[[ ! -d "$iso_done" ]] && mkdir -p "$iso_done"
iso_make="/usr/local/share/iso_make"                     # source folder for ISO file

# create working folders
echo " remastering your iso file"

mkdir -p "$iso_make"
mkdir -p "$iso_make/iso_org"
mkdir -p "$iso_make/iso_new"
mkdir -p "$iso_done/$size"
rm -f "$iso_make/preseed/$seed_file" # Make sure new version is downloaded

currentuser="$(whoami)"

# define spinner function for slow tasks
# courtesy of http://fitnr.com/showing-a-bash-spinner.html
spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# define download function
# courtesy of http://fitnr.com/showing-file-download-progress-using-wget.html
download()
{
    local url=$1
    echo -n "    "
    echo wget $url
    wget --progress=dot $url 2>&1 | grep --line-buffered "%" | \
        sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    echo -ne "\b\b\b\b"
    echo " DONE"
}

downloadrepo()
{
    local url=$1
    echo -n "    "
    cmd="sudo curl -LJO $url"
    echo "$cmd"
    sudo curl -LJO $url 2>&1 | grep --line-buffered "%" | \
        sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    echo -ne "\b\b\b\b"
    echo " DONE"
}

# define function to check if program is installed
# courtesy of https://gist.github.com/JamieMason/4761049
function program_is_installed {
    # set to 1 initially
    local return_=1
    # set to 0 if not found
    type $1 >/dev/null 2>&1 || { local return_=0; }
    # return value
    echo $return_
}

# ask if script runs without sudo or root priveleges
# if [ $currentuser != "root" ]; then
#     echo " you need sudo privileges to run this script, or run it as root"
#     exit 1
# fi

# print a pretty header
echo
echo " +---------------------------------------------------+"
echo " |          UNATTENDED (X)UBUNTU ISO MAKER           |"
echo " +---------------------------------------------------+"
echo

#check that we are in ubuntu 16.04+ or higher

case "$(lsb_release -rs)" in
    16*|18*|20|22*) vge1604="yes" ;;
    *) vge1604="" ;;
esac

#get the latest versions of Ubuntu LTS
cd $iso_from

iso_makehtml=$pathToScript/Resources/tmphtml
sudo rm $iso_makehtml >/dev/null 2>&1
wget -O $iso_makehtml 'http://cdimage.ubuntu.com/' >/dev/null 2>&1

prec=$(fgrep Precise $iso_makehtml | head -1 | awk '{print $3}' | sed 's/href=\"//; s/\/\"//')
trus=$(fgrep Trusty $iso_makehtml | head -1 | awk '{print $3}' | sed 's/href=\"//; s/\/\"//')
xenn=$(fgrep Xenial $iso_makehtml | head -1 | awk '{print $3}' | sed 's/href=\"//; s/\/\"//')
bion=$(fgrep Bionic $iso_makehtml | head -1 | awk '{print $3}' | sed 's/href=\"//; s/\/\"//')
foca=$(fgrep Focal  $iso_makehtml | head -1 | awk '{print $3}' | sed 's/href=\"//; s/\/\"//')
prec_vers=$(fgrep Precise $iso_makehtml | head -1 | awk '{print $6}')
trus_vers=$(fgrep Trusty $iso_makehtml | head -1 | awk '{print $6}')
xenn_vers=$(fgrep Xenial $iso_makehtml | head -1 | awk '{print $6}')
bion_vers=$(fgrep Bionic $iso_makehtml | head -1 | awk '{print $6}')
foca_vers=$(fgrep Focal  $iso_makehtml | head -1 | awk '{print $6}')

name="XUB20ARK$size"

while true; do
    echo " Which ubuntu edition would you like to remaster:"
    echo
    echo "  [1] Ubuntu $prec LTS Server amd64 - Precise Pangolin"
    echo "  [2] Ubuntu $trus LTS Server amd64 - Trusty Tahr"
    echo "  [3] Ubuntu $xenn LTS Server amd64 - Xenial Xerus"
    echo "  [4] Ubuntu $bion LTS Server amd64 - Bionic Beaver"
    echo "  [5] Ubuntu $foca LTS Server amd64 - Focal Fossa"
    echo "  [6] Ubuntu $foca T2Mac Live amd64 - Focal Fossa"
    echo
    #    read -ep " please enter your preference: [1|2|3|4]|5|6: " -i "6" ubver
    read -ep " please enter your preference: [1|2|3|4]|5|6:] " ubver
    case $ubver in
        [1]* )  download_file="ubuntu-$prec_vers-server-amd64.iso"           # filename of the iso to be downloaded
                download_location="http://cdimage.ubuntu.com/releases/$prec/"     # location of the file to be downloaded
                new_iso_name="$name_ubuntu-$prec_vers-server-amd64-unattended" # filename of the new iso file to be created
                break;;
	[2]* )  download_file="ubuntu-$trus_vers-server-amd64.iso"             # filename of the iso to be downloaded
                download_location="http://cdimage.ubuntu.com/releases/$trus/"     # location of the file to be downloaded
                new_iso_name="$name_ubuntu-$trus_vers-server-amd64-unattended"   # filename of the new iso file to be created
                break;;
        [3]* )  download_file="ubuntu-$xenn_vers-server-amd64.iso"
                download_location="http://cdimage.ubuntu.com/releases/$xenn/"
                new_iso_name="$name_ubuntu-$xenn_vers-server-amd64-unattended"
                break;;
        [4]* )  download_file="ubuntu-18.04.4-server-amd64.iso"
                download_location="http://releases.ubuntu.com/18.04/"
                new_iso_base="$name-ubuntu-18.04.4-server-amd64-unattended"
                new_iso_name="$name-ubuntu-18.04.4-server-amd64-unattended"
                break;;
        [5]* )  download_file="ubuntu-20.04.1-legacy-server-amd64.iso"
                download_location="https://cdimage.ubuntu.com/ubuntu-legacy-server/releases/20.04/release/"
                new_iso_base="ubuntu-20.04.1-legacy-server-amd64-unattended"
                new_iso_name="$name-ubuntu-20.04.1-legacy-server-amd64-unattended"
		new_firmware="cdimage.debian.org/cdimage/unofficial/non-free/firmware/bullseye/current"
                break;;
        [6]* )  download_file="ubuntu-20.04.iso"
                download_location="https://github.com/marcosfad/mbp-ubuntu/releases/download/v20.04-5.17.1-1/"
                new_iso_base="ubuntu-20.04"
                new_iso_name="$name-ubuntu-20.04"
		new_firmware="cdimage.debian.org/cdimage/unofficial/non-free/firmware/bullseye/current"
                break;;
        * ) echo " please answer [1], [2], [3], [4], [5]:";;
    esac
done

if [ -f /etc/timezone ]; then
    timezone=`cat /etc/timezone`
elif [ -h /etc/localtime ]; then
    timezone=`readlink /etc/localtime | sed "s/\/usr\/share\/zoneinfo\///"`
else
    checksum=`md5sum /etc/localtime | cut -d' ' -f1`
    timezone=`find /usr/share/zoneinfo/ -type f -exec md5sum {} \; | grep "^$checksum" | sed "s/.*\/usr\/share\/zoneinfo\///" | head -n 1`
fi

# ask the user questions about his/her preferences
read -ep " please enter your preferred timezone: " -i "${timezone}" timezone
read -ep " please enter your preferred username: " -i "econ-ark" username
read -ep " please enter your preferred password: " -i "kra-noce" password
printf "\n"
read -ep " confirm your preferred password: " -i "kra-noce" password2
printf "\n"
read -ep " Make ISO bootable via USB: " -i "yes" bootable

# check if the passwords match to prevent headaches
if [[ "$password" != "$password2" ]]; then
    echo " your passwords do not match; please restart the script and try again"
    echo
    exit
fi

# download the ubuntu iso. If it already exists, do not delete in the end.
cd $iso_from
if [[ ! -f $iso_from/$download_file ]]; then
    echo -n " downloading $download_file: "
    if [[ "$download_location" == *"github"* ]]; then
	[[ -e livecd.zip ]] && rm livecd.zip
	downloadrepo "$download_location""livecd.zip"
	unzip livecd.zip
	mv home/runner/work/mbp-ubuntu/mbp-ubuntu/$download_file ./$download_file
	seed_file="econ-ark-mbp.seed"
    else
	download "$download_location$download_file"
    fi
fi
if [[ ! -f $iso_from/$download_file ]]; then
    echo "Error: Failed to download ISO: $download_location$download_file"
    echo "This file may have moved or may no longer exist."
    echo
    echo "You can download it manually and move it to $iso_from/$download_file"
    echo "Then run this script again."
    exit 1
fi

cd $iso_make
# # download rc.local file
# [[ -f $iso_make/$rclocal_file ]] && rm $iso_make/$rclocal_file

# echo -n " downloading $rclocal_file: "
# download "$online/$files_for_target/$rclocal_file"

# # download econ-ark seed file
# [[ -f $iso_make/$seed_file ]] && rm $iso_make/$seed_file 

# echo -n " downloading $seed_file: "
# download "$online/$seed_file"


# install required packages
if [ $(program_is_installed "mkpasswd") -eq 0 ] \
       || [ $(program_is_installed "mkisofs") -eq 0 ] \
       || [ $(program_is_installed "isohybrid") -eq 0 ]; then
    echo " installing required packages"
    (sudo apt-get -y update > /dev/null 2>&1) &
    spinner $!
    sudo apt-get -y install whois genisoimage syslinux syslinux-utils
    # (sudo apt-get -y install whois genisoimage syslinux > /dev/null 2>&1) &
    # spinner $!
fi

if [[ $bootable == "yes" ]] || [[ $bootable == "y" ]]; then
    if [ $(program_is_installed "isohybrid") -eq 0 ]; then
	# Version Greater Equal 16.04
	if [[ $vge1604 == "yes" || $(lsb_release -cs) == "artful" ]]; then
            (apt-get -y install syslinux syslinux-utils > /dev/null 2>&1) &
            spinner $!
	else
            (apt-get -y install syslinux > /dev/null 2>&1) &
            spinner $!
	fi
    fi
fi

# mount the image
if grep -qs $iso_make/iso_org /proc/mounts ; then
    echo " image is already mounted"
    echo " unmounting before remounting (to make sure latest version is what is mounted)"
    echo '(sudo umount $iso_make/iso_org )'
    (sudo umount $iso_make/iso_org )
fi

echo 'Mounting '$download_file' as '$iso_make/iso_org
sudo cp $iso_from/$download_file /tmp/$download_file
echo mount -o loop /tmp/$download_file $iso_make/iso_org
(sudo mount -o loop /tmp/$download_file $iso_make/iso_org > /dev/null 2>&1)

# copy the iso contents to the working directory
echo 'Copying the iso contents from iso_org to iso_new'
cmd="( sudo rsync -rai --delete $iso_make/iso_org/ $iso_make/iso_new >/dev/null ) &"
echo "$cmd"
eval "$cmd"

spinner $!

# # wiki.debian.org/DebianInstaller/NetbootFirmware
# cd $iso_make/iso_new/install
# [ -f initrd.gz.orig ] || sudo mv initrd.gz initrd.gz.orig
# cd ../..
# [ -f firmware.cpio.gz ] || sudo wget http://cdimage.debian.org/cdimage/unofficial/non-free/firmware/stable/current/firmware.cpio.gz
# cd $iso_make/iso_new/install
# sudo chmod a+w .

# cmd="sudo cat initrd.gz.orig ../../firmware.cpio.gz > initrd.gz"
# echo "$cmd"
# eval "$cmd"
# sudo chown root:root initrd.gz
# sudo chmod a-w .

new_firmware="cdimage.debian.org/cdimage/unofficial/non-free/firmware/bullseye/current" ; iso_make="/usr/local/share/iso_make"
pushd . ; cd $iso_make; [[ ! -d firmware ]] && (cmd="sudo wget https://$new_firmware/firmware.zip" ; echo "$cmd" ; eval "$cmd" ; mkdir -p firmware ; sudo unzip firmware.zip -d firmware; sudo rm -f firmware.zip) ; popd

echo sudo cp -r $iso_make/firmware $iso_make/iso_new/firmware
sudo cp -r $iso_make/firmware $iso_make/iso_new/firmware

# copy the seed file to the iso
cmd="sudo cp -r $pathToScript/$ForISO/* $iso_make/iso_new/preseed/"
echo "$cmd"
eval "$cmd"

# Goal: Concentrate as many mods as possible in a single directory: EFI/BOOT
# (A few things, like .seed files, must be put in other directories)

# copy "label" file ARKINSTALL (the .disk_label and .disk_label2 files are special icon files
# generated by MacOS that contain bitmap images of the name of the drive created manually)
# That name, ARKINSTALL, is stored in .disk_label.contentDetails
# The new icons only appear on a few machines (e.g. Retina 2014 MBPro)
sudo chmod -Rf a+rw $iso_make

[[ -e $iso_make/iso_new/EFI/BOOT ]] && sudo cp $pathToScript/Files/For-Target/sys_root_dir/EFI/BOOT/ARKINSTALL.disk_label     $iso_make/iso_new/EFI/BOOT/.disk_label
[[ -e $iso_make/iso_new/EFI/BOOT ]] && sudo cp $pathToScript/Files/For-Target/sys_root_dir/EFI/BOOT/ARKINSTALL.disk_label_2x  $iso_make/iso_new/EFI/BOOT/.disk_label_2x
[[ -e $iso_make/iso_new/EFI/BOOT ]] && sudo echo ARKINSTALL                                      > $iso_make/iso_new/EFI/BOOT/.disk_label.contentDetails
[[ -e $iso_make/iso_new/EFI/BOOT ]] && sudo cp $pathToScript/Files/For-Target/sys_root_dir/EFI/BOOT/Econ-ARK.VolumeIcon.icns   $iso_make/iso_new/EFI/BOOT/.VolumeIcon.icns
[[ -e $iso_make/iso_new/EFI/BOOT ]] && sudo cp $pathToScript/Files/For-Target/sys_root_dir/EFI/BOOT/Econ-ARK.VolumeIcon.icns   $iso_make/iso_new/.VolumeIcon.icns

[[ -e $iso_make/iso_new/EFI/BOOT ]] && sudo cp $pathToScript/Files/For-Target/sys_root_dir/EFI/BOOT/Econ-ARK.disk_label     $iso_make/iso_new/preseed/Econ-ARK.disk_label
[[ -e $iso_make/iso_new/EFI/BOOT ]] && sudo cp $pathToScript/Files/For-Target/sys_root_dir/EFI/BOOT/Econ-ARK.disk_label_2x  $iso_make/iso_new/preseed/Econ-ARK.disk_label_2x
[[ -e $iso_make/iso_new/EFI/BOOT ]] && sudo echo Econ-ARK                                      > $iso_make/iso_new/preseed/Econ-ARK.disk_label.contentDetails
[[ -e $iso_make/iso_new/EFI/BOOT ]] && sudo cp $pathToScript/Files/For-Target/sys_root_dir/EFI/BOOT/Econ-ARK.VolumeIcon.icns   $iso_make/iso_new/preseed/Econ-ARK.VolumeIcon.icns

# Constraint: Nothing can be copied from the installer ISO to target
# because the system that installs everything derives instead from initrd
# and it is NOT worth it to try to change initrd
# So everything that goes on the target must come from somewhere outside of /


# set late_command

set -o noglob  # Needed for proper variable evaluation in late_command

# Connect the busybox installer's bindings to the target machine
# (allows internet from chroot)
late_command="mount --bind /dev /target/dev ;\
   mount --bind /dev/pts /target/dev/pts ;\
   mount --bind /proc /target/proc ;\
   mount --bind /sys /target/sys ;\
   mount --bind /run /target/run ;\
   [[ -e /sys/firmware/efi/efivars ]] && mount --bind /sys/firmware/efi/efivars /target/sys/firmware/efi/efivars "

# Update app install info and (re)install git
late_command+=";\
   chroot /target apt -y update ;\
   chroot /target apt -y reinstall git ;\
   chroot /target apt -y install apt-utils"

# ;\
    #   chroot /target apt -y install netplan.io ;\
    #   chroot /target netplan generate ;\
    #   chroot /target netplan apply
# Make place for, and retrieve, econ-ark-tools
late_command+=";\
   chroot /target mkdir -p /usr/local/share/data/GitHub/econ-ark  ;\
   [[ ! -e /target/usr/local/share/data/GitHub/econ-ark/econ-ark-tools ]] && chroot /target git clone --depth 1 --branch $git_branch https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools ;\
   chmod -R a+rwx /target/usr/local/share/data/GitHub/econ-ark/econ-ark-tools/* /target/usr/local/share/data/GitHub/econ-ark/econ-ark-tools/.*[0-z]* "

# If there's a directory there already (sometimes linux creates an empty one), delete it,
# then link /var/local to the collection of downloaded files for the target
late_command+=";\
   chroot /target rm -Rf /var/local ;\
   chroot /target ln -s /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target /var/local ;\
   chroot /target rm -f /var/local/status/Size-To-Make-Is-* ;\
   chroot /target touch /var/local/status/Size-To-Make-Is-\$(echo $size) ;\
   [[ "'"$(/cdrom/preseed/*.iso)"'" != '"''"' ]] &>/dev/null && mkdir -p /target/installer && cp /cdrom/preseed/*.iso /target/installer ;\
   chroot /target cat /etc/apt/sources.list | grep -v cdrom > /tmp/apt-sources_without_cdrom.list  ;\
   mv /tmp/apt-sources_without_cdrom.list /etc/apt/sources.list"

#   if [[ ! -L /target/var/local ]]; then chroot /target rm -Rf /var/local ; chroot /target ln -s /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target /var/local ; fi ;\
    #   [[ -d /target/var/local ]] && rm -Rf /target/var/local ;\
    #   chroot /target echo \$(echo $size > /target/usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target/About_This_Install/machine-size.txt) ;\

# late_command_finish contains setup stuff also used in cloud-init
late_command+=";\
   chroot /target /bin/bash -c "'"/var/local/late_command_finish.sh 2>&1 |& tee /var/local/status/late_command_finish.log"'" "

# Run the start script and log the results
late_command+=";\
   chroot /target /bin/bash -c "'"/var/local/tools/start-with-log.sh"'" " 

# late_command will disappear in ubiquity, replaced by ubiquity-success-command which may not be the same thing
# https://bugs.launchpad.net/ubuntu/+source/grub2/+bug/1867092

cd "$pathToScript"

# If it exists, get the last late_command
late_command_last=""
[[ -e $ForTarget/late_command.sh ]] && late_command_last="$(< $ForTarget/late_command.sh)" #; echo "$late_command_last"

# Don't treat "Size-To-Make-Is" choice as meaningful for (below) detecting a change to late_command
late_command_curr_purged="$(echo $late_command      | sed -e 's/Size-To-Make-Is-MAX/Size-To-Make/g' | sed -e 's/Size-To-Make-Is-MIN/Size-To-Make/g')" #; echo "$late_command_curr_purged"
late_command_last_purged="$(echo $late_command_last | sed -e 's/Size-To-Make-Is-MAX/Size-To-Make/g' | sed -e 's/Size-To-Make-Is-MIN/Size-To-Make/g')" #; echo "$late_command_last_purged"

# Create a human-readable and bash executable version of late_command
# Running late_command.sh should convert existing machine to XUBARK
echo '#!/bin/bash' > $ForTarget/late_command.sh
echo '# For explanations, see econ-ark-tools/Virtual/Machine/ISO-maker/create-unattended-iso script' >> $ForTarget/late_command.sh
echo '' >> $ForTarget/late_command.sh
echo '#!/bin/sh' > $iso_make/iso_new/preseed/late_command_busybox.sh
echo '' >> $iso_make/iso_new/preseed/late_command_busybox.sh

echo "$late_command_curr_purged" | tr ';' \\n | sed 's|^ ||g'  >> $iso_make/iso_new/preseed/late_command_busybox.sh
echo "$late_command_curr_purged" | tr ';' \\n | sed 's|^ ||g' | sed 's|chroot /target ||g' | grep -v 'bind' | sed 's|/target/|/|g' >> $ForTarget/late_command.sh

# Make the late_command scripts executable
sudo chmod a+x $ForTarget/late_command.sh
sudo chmod a+x $iso_make/iso_new/preseed/late_command_busybox.sh

# Test whether anything has changed that requires a new push
if [[ -z "$(git status --untracked-files=normal --porcelain 2>/dev/null)" ]]; then # -z is zero (empty)
    echo '' ; echo 'Nothing has changed since last commit; continuing'
else
    echo '' ; echo 'You have uncommited changes; please commit them with a commit message and rerun the script'
    exit 1
fi

# cmd="git diff --exit-code $pathToScript/$ForTarget/late_command.sh"
# echo "$cmd"
# eval "$cmd"
# late_command_changed="$?"
# echo "late_command_changed=$late_command_changed"

# if [[ "$late_command_changed" != 0 ]]; then
#     echo ''
#     echo "$ForTarget/late_command has changed."
#     echo '' ; echo 'The diff output is: ' ; echo ''
#     git diff --exit-code $pathToScript/$ForTarget/late_command.sh
#     echo ''
#     echo 'Please git add, commit, push then hit return:'
#     cmd="cd `pwd` ; git add $ForTarget ; git add $ForTarget/late_command.sh ; git commit -m ISOmaker-Update ; git push"
#     echo "$cmd"
#     echo "$cmd" | xclip -i
#     echo "(should be on xclip clipboard - paste in xfce4-terminal via shift-ctrl-v)"
#     read answer
# fi

# if About-This-Install directory does not exist
if [[ ! -e "$pathToScript/$dirExtra/$ATI" ]]; then # create it
    cd "$pathToScript/$dirExtra"
    sudo chmod u+w "$DIR"
    sudo mkdir -p "$DIR/$ATI"
    sudo chmod u+w "$DIR/$ATI"
    sudo touch "$DIR/$ATI/short.git-hash" ; sudo chmod a+rw "$DIR/$ATI/short.git-hash"
    sudo touch "$DIR/$ATI/commit-msg.txt" ; sudo chmod a+rw "$DIR/$ATI/commit-msg.txt"
    sudo echo "$short_hash" > "$DIR/$ATI/short.git-hash"
    sudo echo "$commit_date" > "$DIR/$ATI/commit_date"
    sudo echo "$msg"        > "$DIR/$ATI/commit-msg.txt"
else # update it 
    msg_last="" # Empty message
    about_this_install_changed=""
    # If not empty locally, get it 
    [[ -e "$DIR/$ATI/commit-msg.txt" ]] && msg_last="$(cat $DIR/$ATI/commit-msg.txt)" 
    if [[ "$msg" != "$msg_last" ]] ; then # if there's a different message from last commit
	# And that message is not auto-generated
	if [[ "$msg" != "ISOmaker-Update" && "$msg" != "About-This-Install-Hash-Update" ]]; then
	    # This is a commit hash we want to store for future retrieval
	    sudo echo "$short_hash"  > "$DIR/$ATI/short.git-hash"
	    sudo echo "$msg"         > "$DIR/$ATI/commit-msg.txt"
            sudo echo "$commit_date" > "$DIR/$ATI/commit_date"
	    about_this_install_changed='true'
	fi
    fi
fi

# If anything relevant has changed, require a fix and a push
if [[ "$about_this_install_changed" != "" ]] && [[ "$msg" != "About-This-Install-Hash-Update" ]] && [[ "$msg" != "ISOmaker-Update" ]] && [[ "$msg" != "$msg_last" ]]; then
    echo "$ATI/ or $ATI.md has changed; the new version has been written"
    echo ''
    cmd="git diff --exit-code $pathToScript/$ForTarget/$ATI/"
    echo "$cmd"
    eval "$cmd"
    echo ''
    echo 'Please git add, commit, push then hit return:'
    echo ''
    cmd="cd `pwd` ; git add $DIR/$ATI ; git commit -m 'About-This-Install-Hash-Update' ; git push"
    echo "$cmd"
    echo "$cmd" | xclip -sel clip
    echo "(should be on xclip clipboard - paste in xfce4-terminal via shift-ctrl-v)"
    read answer
fi

# Add late_command to preseed
echo "# setup firstrun script">> $iso_make/iso_new/preseed/$seed_file
echo "d-i preseed/late_command                                    string      $late_command " >> $iso_make/iso_new/preseed/$seed_file

# generate the password hash
pwhash=$(echo $password | mkpasswd -s -m sha-512)
hostname="XUB20ARK"

# update the seed file to reflect the users' choices
# the normal separator for sed is /, but both the password and the timezone may contain it
# so instead, I am using @
sed -i "s@{{username}}@$username@g" $iso_make/iso_new/preseed/$seed_file
sed -i "s@{{pwhash}}@$pwhash@g"     $iso_make/iso_new/preseed/$seed_file
sed -i "s@{{hostname}}@$hostname@g" $iso_make/iso_new/preseed/$seed_file
sed -i "s@{{timezone}}@$timezone@g" $iso_make/iso_new/preseed/$seed_file

# calculate checksum for seed file
seed_checksum=$(md5sum $iso_make/iso_new/preseed/$seed_file)

cd $iso_make/iso_new

# Very ugly to have all on one line using newlines, but very painful
# to try to have it look prettier then convert to single string
if [ "$version" == "base" ]; then
    sudo chmod u+w $iso_make/iso_new/boot/grub/grub.cfg 
    sudo /bin/sed -i 's|set gfxmode=auto|gfxmode=640x480|g' $iso_make/iso_new/boot/grub/grub.cfg
    sudo /bin/sed -i 's|gfxterm|console|g'                  $iso_make/iso_new/boot/grub/grub.cfg
    # 20210215: MacBookPro9,1 now will not boot with standard Autoinstall
    #    seems to give up when thunderbolt does not respond, rather than looking for drives on USB.
    #    noapic kernel argument seems to fix it
    sudo /bin/sed -i 's|set timeout=30|set timeout=10\nmenuentry "Autoinstall Econ-ARK Xubuntu to external USB" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz  console-setup/ask_detect=false keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA keyboard-configuration/variant=USA hostname=xubuntark netcfg/get_hostname=xubuntark   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical DEBCONF_DEBUG=5 nolapic b43.allhwsupport=1 '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "Enable ATA1 (internal drive)" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz console-setup/ask_detect=false hostname=xubuntark netcfg/get_hostname=xubuntark   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical DEBCONF_DEBUG=5 nolapic ---\n	initrd	/install/initrd.gz\n}\nmenuentry "Most Macs" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz  boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical                    nolapic '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "MacBookPro9,1-Mid-2012" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz  boot=casper file=/cdrom/preseed/econ-ark.seed auto=true console-setup/ask_detect=false hostname=mbp91 priority=critical DEBCONF_DEBUG=5 '$modprobe_blacklist' '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "MacBookPro5,1 blacklist=b43-pci-bridge nolapic blacklist=b43-pci-bridge" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical nolapic modprobe.blacklist=b43-pci-bridge verbose nosplash debug '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nsubmenu "Boot debug options ..." {\nmenuentry "acpi=off" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz  boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical console-setup/ask_detect=false hostname=xubuntark-acpi-off                   acpi=off        '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "nolapic noapic irqpoll" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz  boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical console-setup/ask_detect=false hostname=xubark-nolapic-noapic-irqpoll nolapic noapic irqpoll       '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "noapic" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz  boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical console-setup/ask_detect=false hostname=xubark-noapic noapic        '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "acpi=ht" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz  boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical console-setup/ask_detect=false                    acpi=ht        '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "acpi_osi=Linux" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz  boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical                    cpi_osi=Linux '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "pci=noacpi" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz  boot=casper file=/cdrom/preseed/ecopn-ark.seed auto=true priority=critical console-setup/ask_detect=false                    pci=noacpi        '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "pci=noirq" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz  boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical console-setup/ask_detect=false                    pci=noirq        '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "apci=noirq" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz  boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical                    acpi=noacpi        '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "pnpacpi=off" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical                    pnpacpi=off        '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "No kernel arguments" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical  '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "Mac Mini 2018 (noapic efi=noruntime nomodeset)" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical noapic efi=noruntime nomodeset '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\nmenuentry "Mac t2linux" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark-mbp.seed auto=true priority=critical efi=noruntime pcie_ports=compat initcall_blacklist=nvme_init '$modprobe_blacklist' ---\n	initrd	/install/initrd.gz\n}\n}|g' $iso_make/iso_new/boot/grub/grub.cfg
    
    # Delete original options
    /bin/sed -i '/^menuentry "Install Ubuntu Server"/,/^grub_platform/{/^grub_platform/!d}' $iso_make/iso_new/boot/grub/grub.cfg

    sudo /bin/sed -i 's|default install|default install\nlabel auto-install\n  menu label ^Install Econ-ARK Xubuntu (UEFI)\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical DEBCONF_DEBUG=5 nolapic                   '$modprobe_blacklist' ---          \nlabel install\n  menu label ^MacBookPro9,1-Mid-2012 (noapic)\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical                    noapic '$modprobe_blacklist' --- \nmenu begin ^Debug\nmenu title Troubleshooting \nlabel install\n  menu label ^acpi=off\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical                    acpi=off '$modprobe_blacklist' --- \nlabel install\n  menu label ^nolapic noapic irqpoll\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical                    noapic irqpoll '$modprobe_blacklist' --- \nlabel install\n  menu label ^noapic\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical                    noapic '$modprobe_blacklist' ---  \nlabel install\n  menu label ^acpi_osi=Linux\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical                    acpi_osi=Linux '$modprobe_blacklist' --- \nlabel install\n  menu label ^acpi=ht\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical                    acpi=ht '$modprobe_blacklist' --- \nlabel install\n  menu label ^pci=noacpi\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical                    pci=noacpi '$modprobe_blacklist' --- \nlabel install\n  menu label ^apci=noirq\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical                    apci=noirq '$modprobe_blacklist' ---\nlabel install\n  menu label ^aacpi=noirq\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical                    aacpi=noirq '$modprobe_blacklist' ---\nlabel install\n  menu label ^apnpacpi=off\n  kernel /install/vmlinuz\nappend file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical                    apnpacpi=off '$modprobe_blacklist'  ---\nmenu end\n|g'     $iso_make/iso_new/isolinux/txt.cfg
fi

sed -i -r 's/timeout 1/timeout 30/g'     $iso_make/iso_new/isolinux/isolinux.cfg # Somehow this gets changed; change it back

rpl --quiet 'timeout 300' 'timeout 10'  isolinux/isolinux.cfg # Shuts down language choice screen after 10 deciseconds (1 second)

# 32 bit bootloader obtained from Ubuntu-Server 18.04 EFI/BOOT

cp $pathToScript/$ForTarget/Files/For-Target/sys_root_dir/EFI/BOOT/bootia32.efi $iso_make/iso_new/EFI/BOOT
# Some configurations expect the efi file at /boot/efi/EFI/BOOT
mkdir -p $iso_make/iso_new/boot/efi/EFI/BOOT/
cp $iso_make/iso_new/EFI/BOOT/grubx64.efi $iso_make/iso_new/boot/efi/EFI/BOOT/grubx64.efi  
cp $iso_make/iso_new/EFI/BOOT/BOOTx64.EFI $iso_make/iso_new/boot/efi/EFI/BOOT/BOOTx64.EFI

cp -p $iso_make/iso_new/README.diskdefines /tmp
sudo chmod u+w /tmp/README.diskdefines
rpl 'Ubuntu-Server' 'XUBUNTARK modified from Ubuntu-Server' /tmp/README.diskdefines
sudo chmod u-w /tmp/README.diskdefines
mv /tmp/README.diskdefines $iso_make/iso_new

verbosity=""
[[ -e /var/local/status/verbose ]] && verbosity="_verbose"

new_iso_name_full="$Internal-""$new_iso_name-$commit_date-$short_hash$verbosity.iso"
new_iso_plus_full="$Internal-""$new_iso_name-$commit_date-$short_hash-plus$verbosity.iso"

echo 'new_iso_name_full='$new_iso_name_full

[[ -e "$iso_make/$new_iso_name_full" ]] && rm "$iso_make/$new_iso_name_full"
echo " creating the remastered iso"

# cp $iso_make/iso_new/preseed/econ-ark.seed $iso_make/iso_new/preseed/econ-ark.seed_orig
# (cat $iso_make/iso_new/preseed/econ-ark.seed_orig | grep -v late_command) > $iso_make/iso_new/preseed/econ-ark.seed
ISONAME="XUB20ARK$size"
cmd="cd $iso_make/iso_new ; (mkisofs --allow-leading-dots -D -r -V $ISONAME -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $iso_make/$new_iso_name_full . > /dev/null 2>&1)"

mke="$cmd"
echo "$mke"
eval "$mke"

spinner $!

# make iso bootable (for dd'ing to USB stick)
if [[ $bootable == "yes" ]] || [[ $bootable == "y" ]]; then
    isohybrid $iso_make/$new_iso_name_full
fi

# Make a copy of the iso installer in the preseed directory
echo "cp $iso_make/$new_iso_name_full $iso_make/iso_new/preseed"
eval "cp $iso_make/$new_iso_name_full $iso_make/iso_new/preseed"

cmd="cd $iso_make/iso_new ; (mkisofs --allow-leading-dots -D -r -V $ISONAME -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $iso_make/$new_iso_plus_full . > /dev/null 2>&1)"
mke="$cmd"

echo "$mke"
eval "$mke"
# make iso bootable (for dd'ing to USB stick)
if [[ $bootable == "yes" ]] || [[ $bootable == "y" ]]; then
    isohybrid $iso_make/$new_iso_plus_full
fi


# Move it to the destination
cmd="[[ -e $iso_done/$size/$new_iso_name_full ]] && rm $iso_done/$size/$new_iso_name_full"
echo "$cmd"
eval "$cmd"
cmd="mv $iso_make/$new_iso_name_full $iso_done/$size/$new_iso_name_full "
cmd="mv $iso_make/$new_iso_plus_full $iso_done/$size/$new_iso_plus_full "
echo "$cmd"
eval "$cmd"
echo ""

# # Now make a version of the iso that has the original ISO in /var/local; meta!
# cp -p $iso_done/$new_iso_name_full 
# ISONAME="XUB20ARK$size_Meta"
# cmd="cd $iso_make/iso_new ; (mkisofs --allow-leading-dots -D -r -V $ISONAME -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $iso_make/$new_iso_name_full . > /dev/null 2>&1)"

# mke="$cmd"
# echo "$cmd"
# eval "$cmd"

# spinner $!

# # make iso bootable (for dd'ing to USB stick)
# if [[ $bootable == "yes" ]] || [[ $bootable == "y" ]]; then
#     isohybrid $iso_make/$new_iso_name_full
# fi

# # Move it to the destination
# cmd="[[ -e $iso_done/$size/$new_iso_name_full ]] && rm $iso_done/$size/$new_iso_name_full"
# echo "$cmd"
# eval "$cmd"
# cmd="mv $iso_make/$new_iso_name_full $iso_done/$size/$new_iso_name_full "
# echo "$cmd"
# eval "$cmd"
# echo ""
# echo "make-and-move one-liner:"
# echo ''
# echo "pushd . ; $mke ; $cmd ; popd"
# echo ''

# print info to user
echo " -----"
echo " finished remastering your ubuntu iso file"
echo " the new file is located at: $iso_done/$size/$new_iso_name_full"
echo " your username is: $username"
echo " your password is: $password"
echo " your hostname is: $hostname"
echo " your timezone is: $timezone"
echo

echo 'Task finished at:'
datestr=`date +"%Y%m%d-%H%M%S"`
echo "$datestr"
echo ""

# 20220501: Gave up on rclone to Google because it requires a new token every [interval]

# cmd="rclone --progress copy '"$iso_done/$size/$new_iso_name_full"'"
# cmd+=" econ-ark-google-drive:econ-ark@jhuecon.org/Resources/Virtual/Machine/XUBUNTU-$size"
# echo 'To copy to Google drive, execute the command below:'
# echo ''
# echo "$cmd"
# echo "#!/bin/bash" >  "/tmp/rclone-to-Google-Drive_Last-ISO-Made-$size.sh"
# echo "$cmd"        >> "/tmp/rclone-to-Google-Drive_Last-ISO-Made-$size.sh"
# chmod a+x             "/tmp/rclone-to-Google-Drive_Last-ISO-Made-$size.sh"

# unset vars
unset username
unset password
unset hostname
unset timezone
unset pwhash
unset download_file
unset download_location
unset new_iso_name_full
unset new_iso_name_plus
unset iso_from
unset iso_make
unset iso_done
unset tmp
unset seed_file

sudo umount /usr/local/share/iso_make/iso_org

rm "/var/local/status/Size-To-Make-Is-$size"

# uncomment the exit to perform cleanup of drive after run
exit

rm -rf $iso_make/iso_new
rm -rf $iso_make/iso_org
rm -rf $iso_makehtml
