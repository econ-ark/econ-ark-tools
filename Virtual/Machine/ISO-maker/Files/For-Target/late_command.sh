#!/bin/bash
# For explanations, see create-unattended-iso script

apt -y update 
apt -y reinstall git 
mkdir -p /usr/local/share/data/GitHub/econ-ark 
[[ ! -e /usr/local/share/data/GitHub/econ-ark/econ-ark-tools ]] && git clone --depth 1 --branch Make-Installer-ISO-WORKS https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
chmod -R a+rwx /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/* /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/.*[0-z]* 
[[ -d /var/local ]] && rm -Rf /var/local 
if [[ ! -L /var/local ]]
then rm -Rf /var/local 
ln -s /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target /var/local 
fi 
rm -f /var/local/Size-To-Make-Is-* 
touch /var/local/Size-To-Make-Is-$(echo MIN) 
echo $(echo MIN > /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target/About_This_Install/machine-size.txt) 
/bin/bash -c "/var/local/late_command_finish.sh |& tee /var/local/late_command_finish.log" 
/var/local/start-with-log.sh
