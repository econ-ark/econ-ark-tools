#!/bin/bash

# Verbose output if file exists
[[ -e /var/local/status/verbose ]] && set -x && set -v

# Figure out what the target device is 
df -hT > /tmp/target-partition 
cat /tmp/target-partition | grep -v vfat | grep '/dev' | grep -v 'loop' | grep -v 'ude' | grep -v 'tmpf' | cut -d ' ' -f1 | sed 's/.$//' > /tmp/target-dev 
sd=$(cat /tmp/target-dev)

# On Macs, this should allow nice icons when disk is viewed
mkdir -p /EFI/BOOT/
cp /var/local/sys_root_dir/EFI/BOOT/Econ-ARK.disk_label     /EFI/BOOT/Econ-ARK.disk_label 
cp /var/local/sys_root_dir/EFI/BOOT/Econ-ARK.disk_label_2x  /EFI/BOOT/Econ-ARK.disk_label_2x 
cp /var/local/sys_root_dir/EFI/BOOT/Econ-ARK.VolumeIcon.icns /.VolumeIcon.icns 
echo Econ-ARK > /.disk_label.contentDetails

# Tools that allow machine to recognize many devices without open drivers
# e.g., Broadcom modems are common and require firmware-b43-installer
sudo apt-get -y install b43-fwcutter	       
sudo apt-get -y install firmware-b43-installer

