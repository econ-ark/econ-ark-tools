#!/bin/bash
# This gets run by rc.local the first time the VM boots
# It installs the xubuntu-desktop server and other core tools
# The reboot at the end kicks off the running of the finish.sh script
# The GUI launches automatically at the first boot after installation of the desktop

[[ -e /var/local/finished-software-install ]] && rm -f /var/local/finished-software-install
# To redo the whole installation sequence (without having to redownload anything):
# sudo bash -c '(rm -f /var/local/finished-software-install ; rm -f /var/log/firstboot.log ; rm -f /var/log/secondboot.log ; rm -f /home/econ-ark/.firstboot ; rm -f /home/econ-ark/.secondboot)' >/dev/null

# define convenient "download" function
# courtesy of http://fitnr.com/showing-file-download-progress-using-wget.html
download()
{
    local url=$1
    #    echo -n "    "
    wget --progress=dot $url 2>&1 | grep --line-buffered "%" | \
        sed -u -e "s,\.,,g" | awk '{printf("\b\b\b\b%4s", $2)}'
    #    echo -ne "\b\b\b\b"
    #    echo " DONE"
}


# Resources
myuser="econ-ark"  # Don't sudo because it needs to be an environment variable
mypass="kra-noce"  # Don't sudo because it needs to be an environment variable

# stackoverflow.com/questions check-whether-a-user-exists
if id "ubuntu" &>/dev/null; then # Probably created by multipass
    usermod  -l "$myuser" ubuntu
    groupmod -n "$myuser" ubuntu
    usermod  -d /home/"$myuser" -m "$myuser"
    if [ -f /etc/sudoers.d/90-cloudimg-ubuntu ]; then
	/etc/sudoers.d/90-cloud-init-users
    fi
    perl -pi -e "s/ubuntu/$myuser/g;" /etc/sudoers.d/90-cloud-init-users
else
    sudo adduser --disabled-password --gecos "" "$myuser"
    sudo chpasswd <<<"$myuser:$mypass"
fi
