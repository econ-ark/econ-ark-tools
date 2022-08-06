#!/bin/bash

# Verbose output if 'verbose' indicator file exists
[[ -e /var/local/status/verbose ]] && set -x && set -v

# Prevent installation of endless locale information
# the command purges all EXCEPT those listed
sudo locale-gen --purge en_US en_US.UTF-8 && echo 'only locale is en_US'

# On some Macs, this should allow nice icons when disk is viewed:
mkdir -p /EFI/BOOT/
cp /var/local/sys_root_dir/EFI/BOOT/Econ-ARK.disk_label     /EFI/BOOT/Econ-ARK.disk_label 
cp /var/local/sys_root_dir/EFI/BOOT/Econ-ARK.disk_label_2x  /EFI/BOOT/Econ-ARK.disk_label_2x 
cp /var/local/sys_root_dir/EFI/BOOT/Econ-ARK.VolumeIcon.icns /.VolumeIcon.icns 
echo Econ-ARK > /.disk_label.contentDetails

# Tools that allow machine to recognize many devices without open drivers
# e.g., Broadcom modems are common and require firmware-b43-installer
sudo apt-get -y install b43-fwcutter	       
sudo apt-get -y install firmware-b43-installer

cp /var/local/sys_root_dir/etc/default/grub /etc/default/grub
sudo update-grub

