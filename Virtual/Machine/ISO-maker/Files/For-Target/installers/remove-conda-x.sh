#!/bin/bash

cd /home
for dir in */; do  
    user=$(basename $dir)
    if id "$user" >/dev/null 2>&1; then # user exists
	bashrc="/home/$user/.bashrc"
	if [[ -e $bashrc ]]; then
	    cmd="sudo -u $user /usr/local/$CHOSEN/bin/conda init --system --reverse bash"
	    echo "$cmd"
	    sudo /bin/bash -c "$cmd"
	fi
    fi
done

sudo conda install -c conda-forge anaconda-clean

anaconda-clean --yes

rm -Rf /usr/local/anaconda
