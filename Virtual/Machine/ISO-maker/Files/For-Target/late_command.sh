#!/bin/sh
 apt -y update 
 apt -y install git 
 mkdir -p /usr/local/share/data/GitHub/econ-ark /var/local 
 chmod -Rf a+rwx /usr/local/share/data 
 git clone https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
 /bin/bash -c "cd /usr/local/share/data/GitHub/econ-ark/econ-ark-tools
 git checkout $git_branch 
 git pull" 
 rm -f /target/var/local/grub /target/var/local/rc.local 
 cd /target/usr/local/share/data/GitHub/econ-ark/econ-ark-tools cp -r Virtual/Machine/ISO-maker/Files/For-Target/* /target/var/local 
 cd /target/var/local 
 mv /target/etc/rc.local /target/etc/rc.local_orig 
 mv rc.local /target/etc/rc.local 
 mv /target/etc/default/grub /target/etc/default/grub_orig 
 mv grub /target/etc/default/grub 
 chmod 755 /target/etc/default/grub 
 df -hT > /tmp/target-partition 
 cat /tmp/target-partition | grep /$ | cut -d ' ' -f1 | sed 's/.$//' > /tmp/target-dev 
 sd=$(cat /tmp/target-dev) 
 grub-install $sd 
 chmod a+x /var/local/start.sh /var/local/finish.sh /var/local/finish-MAX-Extras.sh /var/local/grub-menu.sh /var/local/late_command.sh 
 chmod a+x /etc/rc.local 
 sleep 24h
