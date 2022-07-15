#!/bin/bash
# For explanations, see econ-ark-tools/Virtual/Machine/ISO-maker/create-unattended-iso script

apt -y update 
apt -y reinstall git 
mkdir -p /usr/local/share/data/GitHub/econ-ark 
[[ ! -e /usr/local/share/data/GitHub/econ-ark/econ-ark-tools ]] && git clone --depth 1 --branch Make-Installer-ISO-WORKS https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
chmod -R a+rwx /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/* /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/.*[0-z]* 
rm -Rf /var/local 
ln -s /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target /var/local 
rm -f /var/local/status/Size-To-Make-Is-* 
touch /var/local/status/Size-To-Make-Is-$(echo MAX) 
echo $(echo MAX > /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target/About_This_Install/machine-size.txt) 
[[ "$(echo /cdrom/preseed/*.iso)" != '' ]] && mkdir -p /installer && cp /cdrom/preseed/*.iso /installer 
/bin/bash -c "/var/local/late_command_finish.sh |& tee /var/local/status/late_command_finish.log" 
/bin/bash -c "/var/local/loggers/start-with-log.sh"
