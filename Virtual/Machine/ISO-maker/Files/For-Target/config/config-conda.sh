#!/bin/bash

if [[ "$#" != 1 ]]; then
    echo "usage: config-conda.sh [miniconda | anaconda]"
    exit 1
fi

export CHOSEN="$1"

if [[ "$(which conda)" == "" ]]; then
    echo conda is not installed so cannot be configured
fi

# Init for every user
cd /home
for dir in */; do  
    export user=$(basename $dir)
    if id "$user" >/dev/null 2>&1; then # user exists
	bashrc="/home/$user/.bashrc"
	if [[ -e $bashrc ]]; then
	    cmd="sudo -u $user cp /home/user/.bashrc /home/user/.bashrc_preconda ; sudo -u $user /usr/local/$CHOSEN/bin/conda init --system bash ; sudo -u $user conda config --add envs_dirs /usr/local/$CHOSEN/envs ; sudo -u $user conda config --add pkgs_dirs /usr/local/$CHOSEN/pkgs; sudo chmod -R a+rw /usr/local/$CHOSEN/envs; sudo chmod -R a+rw /usr/local/$CHOSEN/pkgs "
	    echo "$cmd"
	    eval "$cmd"
	fi
    fi
done

