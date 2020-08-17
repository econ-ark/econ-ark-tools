#!/bin/bash

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

pathToScript=$(dirname `realpath "$0"`)
# pathToScript=/home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/
git_branch="$(git symbolic-ref HEAD 2>/dev/null)" ; git_branch=${git_branch##refs/heads/}
online="https://raw.githubusercontent.com/econ-ark/econ-ark-tools/$git_branch/Virtual/Machine/ISO-maker"
startFile="start.sh"
finishFile="finish.sh"
refindFile="refind-install-MacOS.sh"
EconARKIcon="Drive/Icons/Econ-ARK.VolumeIcon.icns"
EconARKText1="Drive/Labels/Econ-ARK.disk_label"
EconARKText2="Drive/Labels/Econ-ARK.disk_label_2x"

seed_file="econ-ark.seed"
ks_file=ks.cfg
rclocal_file=rc.local

# file names & paths
iso_from="/media/sf_VirtualBox"       # where to find the original ISO
iso_done="/media/sf_VirtualBox/ISO-made/econ-ark-tools"       # where to store the final iso file - shared with host machine
[[ ! -d "$iso_done" ]] && mkdir -p "$iso_done"
iso_make="/usr/local/share/iso_make"  # source folder for ISO file
# create working folders
echo " remastering your iso file"

mkdir -p "$iso_make"
mkdir -p "$iso_make/iso_org"
mkdir -p "$iso_make/iso_new"
mkdir -p "$iso_done/$size"
rm -f "$iso_make/$ks_file" # Make sure new version is downloaded
rm -f "$iso_make/$seed_file" # Make sure new version is downloaded
rm -f "$iso_make/$startFile" # Make sure new version is downloaded
rm -f "$iso_make/$rclocal_file" # Make sure new version is downloaded

datestr=`date +"%Y%m%d-%H%M%S"`
hostname="built-$datestr"
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

# #check that we are in ubuntu 16.04+

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
prec_vers=$(fgrep Precise $iso_makehtml | head -1 | awk '{print $6}')
trus_vers=$(fgrep Trusty $iso_makehtml | head -1 | awk '{print $6}')
xenn_vers=$(fgrep Xenial $iso_makehtml | head -1 | awk '{print $6}')
bion_vers=$(fgrep Bionic $iso_makehtml | head -1 | awk '{print $6}')

name='econ-ark'

# ask whether to include vmware tools or not
while true; do
    echo " which ubuntu edition would you like to remaster:"
    echo
    echo "  [1] Ubuntu $prec LTS Server amd64 - Precise Pangolin"
    echo "  [2] Ubuntu $trus LTS Server amd64 - Trusty Tahr"
    echo "  [3] Ubuntu $xenn LTS Server amd64 - Xenial Xerus"
    echo "  [4] Ubuntu $bion LTS Server amd64 - Bionic Beaver"
    echo
    read -ep " please enter your preference: [1|2|3|4]: " -i "4" ubver
    case $ubver in
        [1]* )  download_file="ubuntu-$prec_vers-server-amd64.iso"           # filename of the iso to be downloaded
                download_location="http://cdimage.ubuntu.com/releases/$prec/"     # location of the file to be downloaded
                new_iso_name="ubuntu-$prec_vers-server-amd64-unattended_$name.iso" # filename of the new iso file to be created
                break;;
	[2]* )  download_file="ubuntu-$trus_vers-server-amd64.iso"             # filename of the iso to be downloaded
                download_location="http://cdimage.ubuntu.com/releases/$trus/"     # location of the file to be downloaded
                new_iso_name="ubuntu-$trus_vers-server-amd64-unattended_$name.iso"   # filename of the new iso file to be created
                break;;
        [3]* )  download_file="ubuntu-$xenn_vers-server-amd64.iso"
                download_location="http://cdimage.ubuntu.com/releases/$xenn/"
                new_iso_name="ubuntu-$xenn_vers-server-amd64-unattended_$name.iso"
                break;;
        [4]* )  download_file="ubuntu-18.04.4-server-amd64.iso"
                download_location="http://releases.ubuntu.com/18.04/"
                new_iso_base="ubuntu-18.04.4-server-amd64-unattended_$name"
                new_iso_name="ubuntu-18.04.4-server-amd64-unattended_$name.iso"
                break;;
        [5]* )  download_file="ubuntu-20.04-legacy-server-amd64.iso"
                download_location="http://cdimage.ubuntu.com/ubuntu-legacy-server/releases/20.04/release/"
                new_iso_base="ubuntu-20.04-legacy-server-amd64-unattended_$name"
                new_iso_name="ubuntu-20.04-legacy-server-amd64-unattended_$name.iso"
                break;;
        * ) echo " please answer [1], [2], [3], [4] or [5]";;
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

# download kickstart file
[[ -f $iso_make/$ks_file ]] && rm $iso_make/$ks_file

echo -n " downloading $ks_file: "
download "$online/$ks_file"

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
( rsync -rai --delete $iso_make/iso_org/ $iso_make/iso_new ) &
spinner $!

# set the language for the installation menu
cd $iso_make/iso_new
# set late_command

late_command="chroot /target curl -L -o /var/local/start.sh $online/$startFile ;\
     chroot /target curl -L -o /var/local/finish.sh $online/$finishFile ;\
     chroot /target curl -L -o /var/local/$refindFile $online/$refindFile ;\
     chroot /target curl -L -o /etc/rc.local $online/$rclocal_file ;\
     chroot /target curl -L -o /var/local/Econ-ARK.VolumeIcon.icns $online/Disk/Icons/Econ-ARK.VolumeIcon.icns ;\
     chroot /target curl -L -o /var/local/Econ-ARK.disk_label      $online/Disk/Labels/Econ-ARK.disklabel    ;\
     chroot /target curl -L -o /var/local/Econ-ARK.disk_label_2x   $online/Disk/Labels/Econ-ARK.disklabel_2x ;\
     chroot /target chmod +x /var/local/start.sh ;\
     chroot /target chmod +x /var/local/finish.sh ;\
     chroot /target chmod +x /var/local/$refindFile ;\
     chroot /target chmod +x /etc/rc.local ;\
     chroot /target mkdir -p /etc/lightdm/lightdm.conf.d ;\
     chroot /target curl -L -o /etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf $online/root/etc/lightdm/lightdm.conf.d/autologin-econ-ark.conf ;\
     chroot /target curl -L -o /var/local/.bash_aliases-add $online/.bash_aliases-add ;\
     chroot /target chmod a+x /var/local/.bash_aliases-add ;\
"

# copy the seed file to the iso
cp -rT $iso_make/$seed_file $iso_make/iso_new/preseed/$seed_file

# copy the kickstart file to the root
cp -rT $iso_make/$ks_file $iso_make/iso_new/$ks_file
chmod 744 $iso_make/iso_new/$ks_file

# copy "label" file ARKINSTALL 
cp $pathToScript/Disk/Labels/ARKINSTALL.disk_label     $iso_make/iso_new/EFI/BOOT/.disk_label
cp $pathToScript/Disk/Labels/ARKINSTALL.disk_label_2x  $iso_make/iso_new/EFI/BOOT/.disk_label_2x
# Wasted a lot of time trying to get .VolumeIcon.icns to work -- failed and not worth the effort
cp $pathToScript/Disk/Icons/os_refit.icns         $iso_make/iso_new/.VolumeIcon.icns

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

## add the install option to the menu

#sudo /bin/sed -i 's|set timeout=30|set timeout=5\nmenuentry "Autoinstall Econ-ARK Xubuntu Server" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US nomodeset acpi=off DEBCONF_DEBUG=5        ---\n	initrd	/install/initrd.gz\n}|g' $iso_make/iso_new/boot/grub/grub.cfg


#sudo /bin/sed -i 's|default install|default auto-install\nlabel auto-install\n  menu label ^Install Econ-ARK Xubuntu Server\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US nomodeset acpi=off DEBCONF_DEBUG=5     ---|g'     $iso_make/iso_new/isolinux/txt.cfg

# 20200801-1240: Try it with only nolapic, per https://askubuntu.com/questions/877648/linux-stuck-on-boot-about-ehci
#sudo /bin/sed -i 's|set timeout=30|set timeout=5\nmenuentry "Autoinstall Econ-ARK Xubuntu Server" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US.UTF-8 nolapic DEBCONF_DEBUG=5     ---\n	initrd	/install/initrd.gz\n}|g' $iso_make/iso_new/boot/grub/grub.cfg
#sudo /bin/sed -i 's|default install|default auto-install\nlabel auto-install\n  menu label ^Install Econ-ARK Xubuntu Server\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US.UTF-8 nolapic DEBCONF_DEBUG=5     ---|g'     $iso_make/iso_new/isolinux/txt.cfg

# 20200801-1239h: The following worked for MBPro-2009 but not for later models
#sudo /bin/sed -i 's|set timeout=30|set timeout=5\nmenuentry "Autoinstall Econ-ARK Xubuntu Server" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US.UTF-8 acpi=ht noapic nolapic apm=off DEBCONF_DEBUG=5     ---\n	initrd	/install/initrd.gz\n}|g' $iso_make/iso_new/boot/grub/grub.cfg
#sudo /bin/sed -i 's|default install|default auto-install\nlabel auto-install\n  menu label ^Install Econ-ARK Xubuntu Server\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US.UTF-8 acpi=ht noapic nolapic apm=off DEBCONF_DEBUG=5     ---|g'     $iso_make/iso_new/isolinux/txt.cfg

#sudo /bin/sed -i 's|set timeout=30|set timeout=5\nmenuentry "Autoinstall Econ-ARK Xubuntu Server" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US.UTF-8 nolapic         ---\n	initrd	/install/initrd.gz\n}|g' $iso_make/iso_new/boot/grub/grub.cfg
#sudo /bin/sed -i 's|default install|default auto-install\nlabel auto-install\n  menu label ^Install Econ-ARK Xubuntu Server\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US nolapcic      ---|g'     $iso_make/iso_new/isolinux/txt.cfg

sudo /bin/sed -i 's|set timeout=30|set timeout=5\nmenuentry "Autoinstall Econ-ARK Xubuntu Server" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "acpi=off" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer acpi=off        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "nolapic" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer nolapic        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "noapic" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer noapic        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "acpi=ht" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer acpi=ht        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "acpi_osi=Linux" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer cpi_osi=Linux ---\n	initrd	/install/initrd.gz\n}\nmenuentry "pci=noacpi" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer pci=noacpi        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "pci=noirq" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer pci=noirq        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "apci=noirq" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer acpi=noacpi        ---\n	initrd	/install/initrd.gz\n}\nmenuentry "pnpacpi=off" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer pnpacpi=off        ---\n	initrd	/install/initrd.gz\n}\n|g' $iso_make/iso_new/boot/grub/grub.cfg

sudo /bin/sed -i 's|default install|default auto-install\nlabel auto-install\n  menu label ^Install Econ-ARK Xubuntu Server\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer ---          \nlabel install\n  menu label ^acpi=off\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer acpi=off --- \nlabel install\n  menu label ^nolapic\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer nolapic --- \nlabel install\n  menu label ^noapic\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer noapic ---  \nlabel install\n  menu label ^acpi_osi=Linux\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer acpi_osi=Linux --- \nlabel install\n  menu label ^acpi=ht\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer acpi=ht --- \nlabel install\n  menu label ^pci=noacpi\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer pci=noacpi --- \nlabel install\n  menu label ^apci=noirq\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer apci=noirq ---\nlabel install\n  menu label ^aacpi=noirq\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer aacpi=noirq ---\nlabel install\n  menu label ^apnpacpi=off\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=developer apnpacpi=off ---\n|g'     $iso_make/iso_new/isolinux/txt.cfg

# sudo /bin/sed -i 's|default install|default auto-install
# label auto-install
#   menu label ^Install Econ-ARK Xubuntu Server
#   kernel /install/vmlinuz
#   append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 ---          #fail IRQ 17
# label install
#   menu label ^acpi=off
#   kernel /install/vmlinuz
#   append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 acpi=off --- #worked to CDROM 
# label install
#   menu label ^nolapic
#   kernel /install/vmlinuz
#   append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 nolapic --- #WORKED COMPLETELY on old ; failed at "No CD-ROM" on new 
# label install
#   menu label ^noapic
#   kernel /install/vmlinuz
#   append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 noapic ---  #fail IRQ 10
# label install
#   menu label ^acpi_osi=Linux
#   kernel /install/vmlinuz
#   append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 acpi_osi=Linux --- # fail IRQ 10
# label install
#   menu label ^acpi=ht
#   kernel /install/vmlinuz
#   append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 acpi=ht --- # old: fail IRQ 17
# label install
#   menu label ^pci=noacpi
#   kernel /install/vmlinuz
#   append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 pci=noacpi --- # old:IRQ ; fail CD-ROM; new:worked at first but then froze at question about unmounting mounted filesystems
# label install
#   menu label ^apci=noirq
#   kernel /install/vmlinuz
#   append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 apci=noirq ---# old: fail IRQ; new: works
# label install
#   menu label ^aacpi=noirq
#   kernel /install/vmlinuz
#   append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 aacpi=noirq ---# old: fail IRQ 17; new:works
# label install
#   menu label ^apnpacpi=off
#   kernel /install/vmlinuz
#   append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US DEBCONF_DEBUG=5 apnpacpi=off ---# fails IRQ 17; new:works
# |g'     $iso_make/iso_new/isolinux/txt.cfg

# Versions below were standard but seems to fail to boot on older machines, with error about EHCI
#sudo /bin/sed -i 's|set timeout=30|set timeout=5\nmenuentry "Autoinstall Econ-ARK Xubuntu Server" {\n	set gfxpayload=keep\n	linux	/install/vmlinuz   boot=casper file=/cdrom/preseed/econ-ark.seed auto=true priority=critical locale=en_US          ---\n	initrd	/install/initrd.gz\n}|g' $iso_make/iso_new/boot/grub/grub.cfg
#sudo /bin/sed -i 's|default install|default auto-install\nlabel auto-install\n  menu label ^Install Econ-ARK Xubuntu Server\n  kernel /install/vmlinuz\n  append file=/cdrom/preseed/econ-ark.seed vga=788 initrd=/install/initrd.gz auto=true priority=critical locale=en_US        ---|g'     $iso_make/iso_new/isolinux/txt.cfg

# berets notes failed (rmdir /cdrom ; ln -s media /cdrom

sed -i -r 's/timeout 1/timeout 30/g'     $iso_make/iso_new/isolinux/isolinux.cfg # 

rpl 'timeout 300' 'timeout 10'  isolinux/isolinux.cfg # Shuts down language choice screen after 10 deciseconds (1 second)

# 32 bit bootloader obtained from Ubuntu-Server 18.04 EFI/BOOT

# sudo mkdir -p $iso_make/iso_new/EFI/BOOT/XUBARK32

# cp /home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/root/EFI/BOOT/BOOTIA32.EFI $iso_make/iso_new/EFI/BOOT/XUBARK32

sudo /bin/bash /home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/root/EFI/BOOT/rename-efi-entry.bash 

[[ -e "$iso_make/$new_iso_name" ]] && rm "$iso_make/$new_iso_name"
echo " creating the remastered iso"

#cmd="cd $iso_make/iso_new ; (mkisofs -isohybrid-gpt-basdat -D -r -V XUBUNTARK -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $iso_make/$new_iso_name . > /dev/null 2>&1)"
cmd="cd $iso_make/iso_new ; (xorriso -as mkisofs -isohybrid-gpt-basdat -D -r -V XUBUNTARK -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $iso_make/$new_iso_name . > /dev/null 2>&1)"
mke="$cmd"
echo "$cmd"
eval "$cmd"
spinner $!

# make iso bootable (for dding to USB stick)
if [[ $bootable == "yes" ]] || [[ $bootable == "y" ]]; then
    isohybrid $iso_make/$new_iso_name
fi

# Move it to the destination
cmd="[[ -e $iso_done/$size/$new_iso_name ]] && rm $iso_done/$size/$new_iso_name"
echo "$cmd"
eval "$cmd"
#cmd="mv $iso_make/$new_iso_name $iso_done/$size/$new_iso_name ; cp $iso_done/$size/$new_iso_name $iso_done/$size/MacVersion-$new_iso_name ; ./MattGadient/isomacprog $iso_done/$size/MacVersion-$new_iso_name"
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
cmd+=" econ-ark-google-drive:econ-ark@jhuecon.org/Resources/Virtual/Machine/XUBUNTU-$size/$new_iso_base"
echo 'To copy to Google drive, execute the command below:'
echo ''
echo "$cmd"

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

exit

umount $iso_make/iso_org
rm -rf $iso_make/iso_new
rm -rf $iso_make/iso_org
rm -rf $iso_makehtml

