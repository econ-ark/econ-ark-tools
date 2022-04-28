#!/bin/sh
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
 grub-install 
 mkdir -p /var/local/About_This_Install 
 wget -O /var/local/About_This_Install/commit-msg.txt https://raw.githubusercontent.com/econ-ark/econ-ark-tools/Make-ISO-Installer/Virtual/Machine/ISO-maker/Files/For-Target/About_This_Install/commit-msg.txt 
 wget -O /var/local/About_This_Install/short.git-hash https://raw.githubusercontent.com/econ-ark/econ-ark-tools/Make-ISO-Installer/Virtual/Machine/ISO-maker/Files/For-Target/About_This_Install/short.git-hash 
 chmod a+x /var/local/start.sh /var/local/finish.sh /var/local/finish-MAX-Extras.sh /var/local/grub-menu.sh /var/local/late_command.sh 
 chmod a+x /etc/rc.local 
 rm -f /var/local/Size-To-Make 
 rm -f /var/local/Size-To-Make 
 touch /var/local/Size-To-Make
