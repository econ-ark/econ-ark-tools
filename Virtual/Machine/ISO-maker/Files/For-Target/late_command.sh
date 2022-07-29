#!/bin/bash
# For explanations, see econ-ark-tools/Virtual/Machine/ISO-maker/create-unattended-iso script

apt -y update 
apt -y reinstall git 
apt -y install apt-utils
mkdir -p /usr/local/share/data/GitHub/econ-ark 
[[ ! -e /usr/local/share/data/GitHub/econ-ark/econ-ark-tools ]] && git clone --depth 1 --branch master https://github.com/econ-ark/econ-ark-tools /usr/local/share/data/GitHub/econ-ark/econ-ark-tools 
chmod -R a+rwx /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/* /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/.*[0-z]* 
rm -Rf /var/local 
ln -s /usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target /var/local 
rm -f /var/local/status/Size-To-Make-Is-* 
touch /var/local/status/Size-To-Make-Is-$(echo MAX) 
[[ "$(/cdrom/preseed/*.iso)" != '' ]] &>/dev/null && mkdir -p /installer && cp /cdrom/preseed/*.iso /installer 
cat /etc/apt/sources.list | grep -v cdrom > /tmp/apt-sources_without_cdrom.list 
mv /tmp/apt-sources_without_cdrom.list /etc/apt/sources.list
/bin/bash -c "/var/local/late_command_finish.sh |& tee /var/local/status/late_command_finish.log" 
/bin/bash -c "/var/local/tools/start-with-log.sh"
