#!/bin/bash
# Adapted from netson github create-unattended/create-unattended-iso.sh
# Run this with a command like:
# ./create-unattended-iso_Econ-ARK-by-size.sh MIN
# (or MAX to create the richly endowed machine)

if [ "$TERM" == "dumb" ]; then
    echo 'This script should be run from a smart terminal.'
    echo 'But $TERM='"$TERM"' probably because running in emacs shell'
    echo ''
    exit 1
fi

version="base" # or "full" for debugging (too-many-options) on the grub menu

if [ "$#" -ne 1 ]; then
    echo "Wrong number of arguments:"
    echo "usage: ${0##*/} MIN|MAX"
    exit 1
else
    if ( [ ! "$1" == "MIN" ] && [ ! "$1" == "MAX" ] ); then
	echo "usage: ${0##*/} MIN|MAX"
	exit 2
    fi
fi

size="$1"

echo "size_to_build=$size"

# Keep track locally of what was the most recently built version
rm    "$pathToScript/Size-To-Make-Is-MIN"
rm    "$pathToScript/Size-To-Make-Is-MAX"
touch "$pathToScript/Size-To-Make-Is-$size"

pathToScript=$(dirname `realpath "$0"`)
# pathToScript=/home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker

# Names/paths of local and remote files
ForTarget="Files/For-Target"
ForISO="Files/For-ISO"
# Allow for branches to test alternative builds
git_branch="$(git symbolic-ref HEAD 2>/dev/null)" ; git_branch=${git_branch##refs/heads/}
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
#rm -f "$iso_make/$ks_file" # Make sure new version is downloaded
rm -f "$iso_make/preseed/$seed_file" # Make sure new version is downloaded

datestr=`date +"%Y%m%d-%H%M%S"`
hostname="$size-$datestr"
currentuser="$( whoami)"

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
    wget --progress=dot $url 2>&1 | grep --line-buffered "%" | \
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

# print a pretty header
echo
echo " +---------------------------------------------------+"
echo " |            UNATTENDED UBUNTU ISO MAKER            |"
echo " +---------------------------------------------------+"
echo

# ask if script runs without sudo or root priveleges
if [ $currentuser != "root" ]; then
    echo " you need sudo privileges to run this script, or run it as root"
    exit 1
fi

#check that we are in ubuntu 16.04+

case "$(lsb_release -rs)" in
    16*|18*|20*) vge1604="yes" ;;
    *) vge1604="" ;;
esac

#get the latest versions of Ubuntu LTS
cd $iso_from

iso_makehtml=$iso_make/tmphtml
rm $iso_makehtml >/dev/null 2>&1
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

name="XUB20ARK-$size"

# ask whether to include vmware tools or not
while true; do
    echo " which ubuntu edition would you like to remaster:"
    echo
    echo "  [1] Ubuntu $prec LTS Server amd64 - Precise Pangolin"
    echo "  [2] Ubuntu $trus LTS Server amd64 - Trusty Tahr"
    echo "  [3] Ubuntu $xenn LTS Server amd64 - Xenial Xerus"
    echo "  [4] Ubuntu $bion LTS Server amd64 - Bionic Beaver"
    echo "  [5] Ubuntu $foca LTS Server amd64 - Focal Fossa"
    echo
    read -ep " please enter your preference: [1|2|3|4]: " -i "5" ubver
    case $ubver in
        [1]* )  download_file="ubuntu-$prec_vers-server-amd64.iso"           # filename of the iso to be downloaded
                download_location="http://cdimage.ubuntu.com/releases/$prec/"     # location of the file to be downloaded
                new_iso_name="$name_ubuntu-$prec_vers-server-amd64-unattended.iso" # filename of the new iso file to be created
                break;;
	[2]* )  download_file="ubuntu-$trus_vers-server-amd64.iso"             # filename of the iso to be downloaded
                download_location="http://cdimage.ubuntu.com/releases/$trus/"     # location of the file to be downloaded
                new_iso_name="$name_ubuntu-$trus_vers-server-amd64-unattended.iso"   # filename of the new iso file to be created
                break;;
        [3]* )  download_file="ubuntu-$xenn_vers-server-amd64.iso"
                download_location="http://cdimage.ubuntu.com/releases/$xenn/"
                new_iso_name="$name_ubuntu-$xenn_vers-server-amd64-unattended.iso"
                break;;
        [4]* )  download_file="ubuntu-18.04.4-server-amd64.iso"
                download_location="http://releases.ubuntu.com/18.04/"
                new_iso_base="$name-ubuntu-18.04.4-server-amd64-unattended"
                new_iso_name="$name-ubuntu-18.04.4-server-amd64-unattended.iso"
                break;;
        [5]* )  download_file="ubuntu-20.04-legacy-server-amd64.iso"
                download_location="http://cdimage.ubuntu.com/ubuntu-legacy-server/releases/20.04/release/"
                new_iso_base="ubuntu-20.04-legacy-server-amd64-unattended"
                new_iso_name="$name-ubuntu-20.04-legacy-server-amd64-unattended.iso"
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
    download "$download_location$download_file"
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
# download rc.local file
[[ -f $iso_make/$rclocal_file ]] && rm $iso_make/$rclocal_file

echo -n " downloading $rclocal_file: "
download "$online/$rclocal_file"

# download econ-ark seed file
[[ -f $iso_make/$seed_file ]] && rm $iso_make/$seed_file 

echo -n " downloading $seed_file: "
download "$online/$seed_file"

# # download kickstart file
# [[ -f $iso_make/$ks_file ]] && rm $iso_make/$ks_file

# echo -n " downloading $ks_file: "
# download "$online/$ks_file"

# install required packages
echo " installing required packages"
if [ $(program_is_installed "mkpasswd") -eq 0 ] || [ $(program_is_installed "mkisofs") -eq 0 ]; then
    (apt-get -y update > /dev/null 2>&1) &
    spinner $!
    (apt-get -y install whois genisoimage > /dev/null 2>&1) &
    spinner $!
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
    (umount $iso_make/iso_org )
fi

echo 'Mounting '$download_file' as '$iso_make/iso_org
cp $iso_from/$download_file /tmp/$download_file
(mount -o loop /tmp/$download_file $iso_make/iso_org > /dev/null 2>&1)

# copy the iso contents to the working directory
echo 'Copying the iso contents from iso_org to iso_new'
cmd="( rsync -rai --delete $iso_make/iso_org/ $iso_make/iso_new ) &"
echo "$cmd"
( rsync -rai --delete $iso_make/iso_org/ $iso_make/iso_new ) &
spinner $!

# copy the seed file to the iso
cmd="cp -rT $pathToScript/$ForISO/$seed_file $iso_make/iso_new/preseed/$seed_file"
echo "$cmd"
eval "$cmd"

# copy "label" file ARKINSTALL (the .disk_label and .disk_label2 files are special icon files
# generated by MacOS that contain bitmap images of the name of the drive created manually)
# That name, ARKINSTALL, is stored in .disk_label.contentDetails but changing it here does no change the icons
cp $pathToScript/Disk/Labels/ARKINSTALL.disk_label     $iso_make/iso_new/EFI/BOOT/.disk_label
cp $pathToScript/Disk/Labels/ARKINSTALL.disk_label_2x  $iso_make/iso_new/EFI/BOOT/.disk_label_2x
echo ARKINSTALL                                      > $iso_make/iso_new/EFI/BOOT/.disk_label.contentDetails
cp $pathToScript/Disk/Icons/Econ-ARK.VolumeIcon.icns   $iso_make/iso_new/EFI/BOOT/.VolumeIcon.icns
cp $pathToScript/Disk/Icons/Econ-ARK.VolumeIcon.icns   $iso_make/iso_new/.VolumeIcon.icns

cd $iso_make/iso_new
# set late_command 
late_command="chroot /target wget -O /var/local/late_command.sh $online/$ForTarget/late_command.sh ;\
     chroot /target wget -O /var/local/econ-ark.seed    $online/$ForISO/$seed_file ;\
     chroot /target wget -O /var/local/start.sh         $online/$ForTarget/$startFile ;\
     chroot /target wget -O /etc/rc.local               $online/$ForTarget/$rclocal_file ;\
     chroot /target wget -O /var/local/finish.sh        $online/$ForTarget/$finishFile ;\
     chroot /target wget -O /var/local/$finishMAX       $online/$ForTarget/$finishMAX ;\
     chroot /target wget -O /var/local/grub-menu.sh     $online/$ForTarget/grub-menu.sh ;\
     chroot /target wget -O /etc/default/grub           $online/$ForTarget/grub ;\
     chroot /target wget -O /var/local/XUBUNTARK.md     $online/$ForTarget/XUBUNTARK.md ;\
     chroot /target wget -O /var/local/XUBUNTARK-MAX.md $online/$ForTarget/XUBUNTARK-MAX.md ;\
     chroot /target chmod 755 /etc/default/grub       ;\
     chroot /target chmod a+x /var/local/start.sh /var/local/finish.sh /var/local/$finishMAX /var/local/grub-menu.sh /var/local/late_command.sh ;\
     chroot /target chmod a+x /etc/rc.local ;\
     chroot /target rm    -f /var/local/Size-To-Make-Is-MIN ;\
     chroot /target [[ -e /var/local/Size-To-Make-Is-MAX ]] && rm    -f /var/local/Size-To-Make-Is-MAX ;\
     chroot /target touch /var/local/Size-To-Make-Is-$size ;\
     chroot /target mkdir -p   /usr/share/lightdm/lightdm.conf.d /etc/systemd/system/getty@tty1.service.d ;\
     chroot /target wget -O /etc/systemd/system/getty@tty1.service.d/override.conf $online/$ForTarget/root/etc/systemd/system/getty@tty1.service.d/override.conf ;\
     chroot /target chmod 755 /etc/systemd/system/getty@tty1.service.d/override.conf \
"

cd "$pathToScript"
# If it exists, get the last late_command
late_command_last=""
[[ -e $ForTarget/late_command.raw ]] && late_command_last="$(< $ForTarget/late_command.raw)" #; echo "$late_command_last"

# Don't treat "Size-To-Make-Is" choice as meaningful for a change to late_command
late_command_curr_purged="$(echo $late_command      | sed -e 's/Size-To-Make-Is-MAX//g' | sed -e 's/Size-To-Make-Is-MIN//g')" #; echo "$late_command_curr_purged"
late_command_last_purged="$(echo $late_command_last | sed -e 's/Size-To-Make-Is-MAX//g' | sed -e 's/Size-To-Make-Is-MIN//g')" #; echo "$late_command_last_purged"

# Create a human-readable and bash executable version of late_command
echo "#!/bin/bash" > $ForTarget/late_command.sh
echo "$late_command_curr_purged" | tr ';' \\n | sed 's|     ||g' | sed 's|chroot /target ||g' | grep -v $ForTarget/late_command >> $ForTarget/late_command.sh
chmod a+x $ForTarget/late_command.sh

# If the command has changed

git diff --exit-code $pathToScript/$ForTarget/late_command.sh

if [[ "$?" != 0 ]]; then
    echo '$ForTarget/late_command has changed; the new version has been written'
    echo ''
    echo 'Please git add, commit, push then hit return:'
    cmd="cd `pwd` ; git add $ForTarget/late_command.sh ; git add $ForTarget/late_command.raw ; git commit -m ISOmaker-Update-Late-Command ; git push"
    echo "$cmd"
    echo "$cmd" | xclip -i 
    echo "(should be on xclip clipboard - paste in xfce4-terminal via shift-ctrl-v)"
    read answer
fi

# include firstrun script
echo "# setup firstrun script">> $iso_make/iso_new/preseed/$seed_file
echo "d-i preseed/late_command                                    string      $late_command " >> $iso_make/iso_new/preseed/$seed_file

# generate the password hash
pwhash=$(echo $password | mkpasswd -s -m sha-512)

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
    sudo /bin/sed -i 's|set timeout=30|set timeout=10\nmenuentry "Autoinstall Econ-ARK Xubuntu" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 nolapic ---\n	initrd	/install/initrd.gz\n}\nmenuentry "Most Macs" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US                    nolapic ---\n	initrd	/install/initrd.gz\n}\nmenuentry "MacBookPro9,1-Mid-2012 (noapic)" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US noapic  ---\n	initrd	/install/initrd.gz\n}\nsubmenu "Boot debug options ..." {\nmenuentry "acpi=off" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US                    acpi=off        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "nolapic noapic irqpoll" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US                    noapic irqpoll       ---\n	initrd	/install/initrd.gz\n}\nmenuentry "noapic" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US                    noapic        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "acpi=ht" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US                    acpi=ht        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "acpi_osi=Linux" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US                    cpi_osi=Linux ---\n	initrd	/install/initrd.gz\n}\nmenuentry "pci=noacpi" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/ecopn-ark.seed auto=true priority=critical locale=en_US                    pci=noacpi        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "pci=noirq" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US                    pci=noirq        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "apci=noirq" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US                    acpi=noacpi        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "pnpacpi=off" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US                    pnpacpi=off        ---\n	initrd	/install/initrd.gz\n}\n}|g' $iso_make/iso_new/boot/grub/grub.cfg
    
    # Delete original options
    /bin/sed -i '/^menuentry "Install Ubuntu Server"/,/^grub_platform/{/^grub_platform/!d}' $iso_make/iso_new/boot/grub/grub.cfg

    sudo /bin/sed -i 's|default install|default install\nlabel auto-install\n  menu label ^Install Econ-ARK Xubuntu (UEFI)\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 nolapic                   ---          \nlabel install\n  menu label ^MacBookPro9,1-Mid-2012 (noapic)\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US                    noapic --- \nmenu begin ^Debug\nmenu title Troubleshooting \nlabel install\n  menu label ^acpi=off\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US                    acpi=off --- \nlabel install\n  menu label ^nolapic noapic irqpoll\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US                    noapic irqpoll --- \nlabel install\n  menu label ^noapic\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US                    noapic ---  \nlabel install\n  menu label ^acpi_osi=Linux\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US                    acpi_osi=Linux --- \nlabel install\n  menu label ^acpi=ht\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US                    acpi=ht --- \nlabel install\n  menu label ^pci=noacpi\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US                    pci=noacpi --- \nlabel install\n  menu label ^apci=noirq\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US                    apci=noirq ---\nlabel install\n  menu label ^aacpi=noirq\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US                    aacpi=noirq ---\nlabel install\n  menu label ^apnpacpi=off\n  kernel /install/vmlinuz\nappend file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US                    apnpacpi=off ---\nmenu end\n|g'     $iso_make/iso_new/isolinux/txt.cfg

    # Delete original options
    sudo /bin/sed -i 's|default install|default auto-install\nlabel auto-install\n  menu label ^Install Econ-ARK Xubuntu Server\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US   ---|g'     $iso_make/iso_new/isolinux/txt.cfg
else
    sudo /bin/sed -i 's|default install|default auto-install\nlabel auto-install\n  menu label ^Install Econ-ARK Xubuntu Server\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 nolapic  ---          \nlabel install\n  menu label ^MacBookPro9,1-Mid-2012 (noapic)\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 noapic --- \nlabel install\n  menu label ^acpi=off\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 acpi=off --- \nlabel install\n  menu label ^nolapic noapic irqpoll\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 noapic irqpoll --- \nlabel install\n  menu label ^noapic\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 noapic ---  \nlabel install\n  menu label ^acpi_osi=Linux\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 acpi_osi=Linux --- \nlabel install\n  menu label ^acpi=ht\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 acpi=ht --- \nlabel install\n  menu label ^pci=noacpi\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 pci=noacpi --- \nlabel install\n  menu label ^apci=noirq\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 apci=noirq ---\nlabel install\n  menu label ^aacpi=noirq\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 aacpi=noirq ---\nlabel install\n  menu label ^apnpacpi=off\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed   vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5      apnpacpi=off ---|g'     $iso_make/iso_new/isolinux/txt.cfg
fi

sed -i -r 's/timeout 1/timeout 30/g'     $iso_make/iso_new/isolinux/isolinux.cfg # Somehow this gets changed; change it back

rpl 'timeout 300' 'timeout 10'  isolinux/isolinux.cfg # Shuts down language choice screen after 10 deciseconds (1 second)

# 32 bit bootloader obtained from Ubuntu-Server 18.04 EFI/BOOT

cp $pathToScript/$ForTarget/root/EFI/BOOT/bootia32.efi $iso_make/iso_new/EFI/BOOT
# Some configurations expect the efi file at /boot/efi/EFI/BOOT
mkdir -p $iso_make/iso_new/boot/efi/EFI/BOOT/
cp $iso_make/iso_new/EFI/BOOT/grubx64.efi $iso_make/iso_new/boot/efi/EFI/BOOT/grubx64.efi  
cp $iso_make/iso_new/EFI/BOOT/BOOTx64.EFI $iso_make/iso_new/boot/efi/EFI/BOOT/BOOTx64.EFI

#sudo /bin/bash /home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/root/EFI/BOOT/rename-efi-entry.bash 

[[ -e "$iso_make/$new_iso_name" ]] && rm "$iso_make/$new_iso_name"
echo " creating the remastered iso"

ISONAME="XUB20ARK$size"
cmd="cd $iso_make/iso_new ; (mkisofs --allow-leading-dots -D -r -V $ISONAME -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $iso_make/$new_iso_name . > /dev/null 2>&1)"


mke="$cmd"
echo "$cmd"
eval "$cmd"

spinner $!

# make iso bootable (for dd'ing to USB stick)
if [[ $bootable == "yes" ]] || [[ $bootable == "y" ]]; then
    isohybrid $iso_make/$new_iso_name
fi

# Move it to the destination
cmd="[[ -e $iso_done/$size/$new_iso_name ]] && rm $iso_done/$size/$new_iso_name"
echo "$cmd"
eval "$cmd"
cmd="mv $iso_make/$new_iso_name $iso_done/$size/$new_iso_name "
echo "$cmd"
eval "$cmd"
echo ""
echo "make-and-move one-liner:"
echo '' 
echo "pushd . ; $mke ; $cmd ; popd"
echo ''

# print info to user
echo " -----"
echo " finished remastering your ubuntu iso file"
echo " the new file is located at: $iso_done/$size/$new_iso_name"
echo " your username is: $username"
echo " your password is: $password"
echo " your hostname is: $hostname"
echo " your timezone is: $timezone"
echo

echo 'Task finished at:'
datestr=`date +"%Y%m%d-%H%M%S"`
echo "$datestr"
echo ""


cmd="rclone --progress copy '"$iso_done/$size/$new_iso_name"'"
cmd+=" econ-ark-google-drive:econ-ark@jhuecon.org/Resources/Virtual/Machine/XUBUNTU-$size/$new_iso_name"
echo 'To copy to Google drive, execute the command below:'
echo ''
echo "$cmd"
echo "#!/bin/bash" >  "/tmp/rclone-to-Google-Drive_Last-ISO-Made-$size.sh"
echo "$cmd"        >> "/tmp/rclone-to-Google-Drive_Last-ISO-Made-$size.sh"
chmod a+x             "/tmp/rclone-to-Google-Drive_Last-ISO-Made-$size.sh"

# uncomment the exit to perform cleanup of drive after run
# unset vars
unset username
unset password
unset hostname
unset timezone
unset pwhash
unset download_file
unset download_location
unset new_iso_name
unset iso_from
unset iso_make
unset iso_done
unset tmp
unset seed_file

umount /usr/local/share/iso_make/iso_org

exit

rm -rf $iso_make/iso_new
rm -rf $iso_make/iso_org
rm -rf $iso_makehtml
