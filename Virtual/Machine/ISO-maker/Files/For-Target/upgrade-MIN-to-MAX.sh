#!/bin/bash
# Run this if you installed the MIN version
# and want to upgrade to the MAX version

cd /var/local/status

if [[ ! -e /var/local/status/Size-To-Make-Is-MIN ]]; then
    echo 'Size-To-Make is not currently MIN'
    exit
fi
    
sudo mv /var/local/status/Size-To-Make-Is-MIN /var/local/status/Size-To-Make-Is-MAX

# Installing anaconda over miniconda doesn't fix the paths 
for dir in */; do  # For other users
    user=$(basename $dir)
    if id "$user" >/dev/null 2>&1; then # user exists
	bashrc="/home/$user/.bashrc"
	if [[ -e $bashrc ]]; then
	    sed -i -e 's|/usr/local/miniconda|/usr/local/anaconda|g' "$bashrc"
	fi
    fi
done

sudo /var/local/finish.sh |& tee /var/local/status/upgrade-MIN-to-MAX.log

