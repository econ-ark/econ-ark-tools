#!/bin/bash
 wget -O /var/local/econ-ark.seed https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-ISO/econ-ark.seed 
 wget -O /var/local/start.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/start.sh 
 wget -O /etc/rc.local https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/rc.local 
 wget -O /var/local/finish.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/finish.sh 
 wget -O /var/local/finish-MAX-Extras.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/finish-MAX-Extras.sh 
 wget -O /var/local/grub-menu.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/grub-menu.sh 
 wget -O /etc/default/grub https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/grub 
 wget -O /var/local/XUBUNTARK-body.md https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/XUBUNTARK-body.md 
 mkdir -p /var/local/About_This_Install 
 wget -O /var/local/About_This_Install/commit-msg.txt https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/About_This_Install/commit-msg.txt 
 wget -O /var/local/About_This_Install/short.git-hash https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/About_This_Install/short.git-hash 
 chmod 755 /etc/default/grub 
 chmod a+x /var/local/start.sh /var/local/finish.sh /var/local/finish-MAX-Extras.sh /var/local/grub-menu.sh /var/local/late_command.sh 
 chmod a+x /etc/rc.local 
 rm -f /var/local/ 
 rm -f /var/local/ 
 touch /var/local/ 
 mkdir -p /usr/share/lightdm/lightdm.conf.d /etc/systemd/system/getty@tty1.service.d 
 wget -O /etc/systemd/system/getty@tty1.service.d/override.conf https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Virtual/Machine/ISO-maker/Files/For-Target/root/etc/systemd/system/getty@tty1.service.d/override.conf 
 mount --bind /dev/pts /target/dev/pts 
 mount --bind /proc /target/proc 
 mount --bind /sys /target/sys 
 mount --bind /sys/firmware/efi/efivars /target/sys/firmware/efi/efivars 
 apt-get --yes purge shim 
 [[ -e /target/boot/efi/EFI/ubuntu ]] && mv /target/boot/efi/EFI/ubuntu /root/ubuntu-efi.bak 
 grub-install 
 update-grub 
 chmod 755 /etc/systemd/system/getty@tty1.service.d/override.conf
