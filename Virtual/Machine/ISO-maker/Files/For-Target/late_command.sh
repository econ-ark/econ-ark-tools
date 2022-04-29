#!/bin/sh
mount --bind /dev /target/dev 
 mount --bind /dev/pts /target/dev/pts 
 mount --bind /proc /target/proc 
 mount --bind /sys /target/sys 
 mount --bind /run /target/run 
 wget -O /var/local/econ-ark.seed https://raw.githubusercontent.com/econ-ark/econ-ark-tools/Make-ISO-Installer/Virtual/Machine/ISO-maker/Files/For-ISO/econ-ark.seed 
 wget -O /var/local/start.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/Make-ISO-Installer/Virtual/Machine/ISO-maker/Files/For-Target/start.sh 
 wget -O /etc/rc.local https://raw.githubusercontent.com/econ-ark/econ-ark-tools/Make-ISO-Installer/Virtual/Machine/ISO-maker/Files/For-Target/rc.local 
 wget -O /var/local/finish.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/Make-ISO-Installer/Virtual/Machine/ISO-maker/Files/For-Target/finish.sh 
 wget -O /var/local/finish-MAX-Extras.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/Make-ISO-Installer/Virtual/Machine/ISO-maker/Files/For-Target/finish-MAX-Extras.sh 
 wget -O /var/local/grub-menu.sh https://raw.githubusercontent.com/econ-ark/econ-ark-tools/Make-ISO-Installer/Virtual/Machine/ISO-maker/Files/For-Target/grub-menu.sh 
 wget -O /var/local/XUBUNTARK-body.md https://raw.githubusercontent.com/econ-ark/econ-ark-tools/Make-ISO-Installer/Virtual/Machine/ISO-maker/Files/For-Target/XUBUNTARK-body.md 
 wget -O /etc/default/grub https://raw.githubusercontent.com/econ-ark/econ-ark-tools/Make-ISO-Installer/Virtual/Machine/ISO-maker/Files/For-Target/grub 
 wget -O /var/local/git_branch https://raw.githubusercontent.com/econ-ark/econ-ark-tools/Make-ISO-Installer/Virtual/Machine/ISO-maker/Files/For-Target/git_branch 
 chmod 755 /etc/default/grub 
 df -hT > /tmp/target-partition 
 cat /tmp/target-partition | grep /$ | cut -d ' ' -f1 | sed 's/.$//' > /tmp/target-dev 
 sd=$(cat /tmp/target-dev) 
 grub-install $sd 
\
