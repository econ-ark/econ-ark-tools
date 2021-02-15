#!/bin/sh
mount --bind /dev /target/dev 
 mount --bind /dev/pts /target/dev/pts 
 mount --bind /proc /target/proc 
 mount --bind /sys /target/sys 
 mount --bind /run /target/run 
 mount --bind /sys/firmware/efi/efivars /target/sys/firmware/efi/efivars 
 wget -O /var/local/econ-ark.seed https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-ISO/econ-ark.seed 
 wget -O /var/local/start.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/start.sh 
 wget -O /etc/rc.local https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/rc.local 
 wget -O /var/local/finish.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/finish.sh 
 wget -O /var/local/finish-MAX-Extras.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/finish-MAX-Extras.sh 
 wget -O /var/local/grub-menu.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/grub-menu.sh 
 wget -O /var/local/XUBUNTARK-body.md https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/XUBUNTARK-body.md 
 wget -O /etc/default/grub https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/grub 
 chmod 755 /etc/default/grub 
 mkdir -p /var/local/About_This_Install 
 wget -O /var/local/About_This_Install/commit-msg.txt https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/About_This_Install/commit-msg.txt 
 wget -O /var/local/About_This_Install/short.git-hash https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/About_This_Install/short.git-hash 
 chmod a+x /var/local/start.sh /var/local/finish.sh /var/local/finish-MAX-Extras.sh /var/local/grub-menu.sh /var/local/late_command.sh 
 chmod a+x /etc/rc.local 
 rm -f /var/local/Size-To-Make 
 rm -f /var/local/Size-To-Make 
 touch /var/local/Size-To-Make 
 mkdir -p /usr/share/lightdm/lightdm.conf.d /etc/systemd/system/getty@tty1.service.d 
 wget -O /etc/systemd/system/getty@tty1.service.d/override.conf https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/root/etc/systemd/system/getty@tty1.service.d/override.conf 
 chmod 755 /etc/systemd/system/getty@tty1.service.d/override.conf 
 apt-get --yes purge shim 
 apt-get --yes purge mokutil 
 chroot cp /boot/efi/EFI/ubuntu/shimx64.efi /root/shimx64.efi_bak 
 chroot cp /boot/efi/EFI/ubuntu/grubx64.efi /boot/efi/EFI/ubuntu/shimx64.efi 
 sed -i 's/COMPRESS=lz4/COMPRESS=gzip/g' /target/etc/initramfs-tools/initramfs.conf 
 update-initramfs -v -c -k all 
 target_efi=$(mount | grep '/target/boot/efi' | cut -d ' ' -f1) 
 target_dev=${target_efi%?} 
 target_swap=${target_dev}4 
 grub-install --verbose --efi-directory=/boot/efi/ --removable $target_dev --no-uefi-secure-boot > /target/var/local/grub-install-test.sh 
 grub-install --verbose --efi-directory=/boot/efi/ --removable $target_dev --no-uefi-secure-boot 
 update-grub 

