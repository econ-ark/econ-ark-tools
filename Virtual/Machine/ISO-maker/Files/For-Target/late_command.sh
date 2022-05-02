#!/bin/sh

 apt -y update 
 apt -y install git 
 apt -y install grub-efi 
 mkdir -p /usr/local/share/data/GitHub/econ-ark /var/local 
 chmod -Rf a+rwx /usr/local/share/data 
 [[ ! -e /usr/local/share/data/GitHub/econ-ark/econ-ark-tools ]] && git clone --depth 1 https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
 /bin/bash -c "cd /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
 git checkout Make-ISO-Installer 
 git pull" 
 [[ -e /var/local ]] && rm -Rf /var/local 
 cp -R /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target /var/local 
 cd /var/local 
 [[ -e /etc/rc.local ]] && mv /etc/rc.local /etc/rc.local_orig 
 [[ -e /var/local/rc.local ]] && mv /var/local/rc.local /etc/rc.local 
 [[ -e /etc/default/grub ]] && [[ -e /var/local/grub ]] && mv /etc/default/grub /etc/default/grub_orig && mv /var/local/grub /etc/default/grub 
 chmod 755 /etc/default/grub 
 update-grub 
 df -hT > /tmp/target-partition 
 cat /tmp/target-partition | grep /$ | cut -d ' ' -f1 | sed 's/.$//' > /tmp/target-dev 
 sd=$(cat /tmp/target-dev) 
 grub-install $sd 
 chmod a+x /var/local/start.sh /var/local/finish.sh /var/local/finish-MAX-Extras.sh /var/local/grub-menu.sh /var/local/late_command.sh /etc/rc.local 
 rm -f /var/local/Size-To-Make 
 rm -f /var/local/Size-To-Make 
 touch /var/local/Size-To-Make 
 mkdir -p /usr/share/lightdm/lightdm.conf.d /etc/systemd/system/getty@tty1.service.d 
 cp /var/local/root/etc/systemd/system/getty@tty1.service.d/override.conf /etc/systemd/system/getty@tty1.service.d/override.conf 
 chmod 755 /etc/systemd/system/getty@tty1.service.d/override.conf 
 apt-get --yes purge shim 
 apt-get --yes purge mokutil 
 sed -i 's/COMPRESS=lz4/COMPRESS=gzip/g' /etc/initramfs-tools/initramfs.conf 
 update-initramfs -v -c -k all 
 in-target apt-get purge -y virtualbox-guest* 
 echo grub-install --verbose --force --efi-directory=/boot/efi/ --removable --no-uefi-secure-boot --target=x86_64-efi > /var/local/grub-install-test.sh 
 grub-install --verbose --force --efi-directory=/boot/efi/ --removable --no-uefi-secure-boot --target=x86_64-efi 
 update-grub
