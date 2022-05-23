#!/bin/bash

 apt -y update 
 apt -y install git 
 apt -y install linux-headers-5.4.0-109-generic 
 mkdir -p /usr/local/share/data/GitHub/econ-ark 
 chmod -Rf a+rwx /usr/local/share/data 
 [[ ! -e /usr/local/share/data/GitHub/econ-ark/econ-ark-tools ]] && sudo -u econ-ark git clone https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
 git config --global --add safe.directory /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
 /bin/bash -c "cd /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
 git checkout Make-Installer-ISO-WORKS 
 git pull" 
 [[ -e /var/local ]] && rm -Rf /var/local 
 cp -R /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target /var/local 
 cd /var/local 
 [[ -e /etc/rc.local ]] && mv /etc/rc.local /etc/rc.local_orig 
 [[ -e /var/local/rc.local ]] && cp /var/local/rc.local /etc/rc.local 
 [[ -e /etc/default/grub ]] && [[ -e /var/local/grub ]] && cp /etc/default/grub /etc/default/grub_orig && mv /var/local/grub /etc/default/grub 
 chmod 755 /etc/default/grub 
 update-grub 
 df -hT > /tmp/target-partition 
 cat /tmp/target-partition | grep /$ | cut -d ' ' -f1 | sed 's/.$//' > /tmp/target-dev 
 sd=$(cat /tmp/target-dev) 
 rm -f /var/local/Size-To-Make 
 rm -f /var/local/Size-To-Make 
 touch /var/local/Size-To-Make 
 mkdir -p /usr/share/lightdm/lightdm.conf.d /etc/systemd/system/getty@tty1.service.d 
 cp /var/local/root/etc/systemd/system/getty@tty1.service.d/override.conf /etc/systemd/system/getty@tty1.service.d/override.conf 
 chmod 755 /etc/systemd/system/getty@tty1.service.d/override.conf 
 apt -y install --reinstall grub-efi-amd64 
 grub-install --verbose --force --efi-directory=/boot/efi/ --removable --target=x86_64-efi --no-uefi-secure-boot 
 apt-get --yes purge shim 
 apt-get --yes purge mokutil 
 apt -y install grub-efi-amd64-bin 
 apt -y install --reinstall grub-pc 
 apt -y --fix-broken install 
 in-target apt-get purge -y virtualbox-guest* 
 /bin/bash -c "[[ -e /boot/efi/EFI/ubuntu/grubx64.efi ]] && cp /boot/efi/EFI/ubuntu/grubx64.efi /boot/efi/EFI/ubuntu/shimx64.efi" 
 update-grub 
 mkdir /installer 
 /bin/bash -c "[[ -d /cdrom ]] && [[ \$(ls -A /cdrom) ]] && cp /cdrom/preseed/XUB*.* /installer/" 
 /bin/bash -c "[[ -d /media/cdrom ]] && [[ \$(ls -A /media/cdrom) ]] && cp /media/cdrom/preseed/XUB*.* /installer/" 
 cp /var/local/Disk/Labels/Econ-ARK.disk_label /Econ-ARK.disk_label 
 cp /var/local/Disk/Labels/Econ-ARK.disk_label_2x /Econ-ARK.disk_label_2x 
 cp /var/local/Disk/Icons/Econ-ARK.VolumeIcon.icns /Econ-ARK.VolumeIcon.icns 
 echo Econ-ARK > /.disk_label.contentDetails
