#!/bin/bash

if [[ "$#" != 1 ]]; then
    echo "usage: config-conda.sh [miniconda | anaconda]"
    exit 1
fi

export CHOSEN="$1"

if [[ "$(which conda)" == "" ]]; then
    echo conda is not installed so cannot be configured
fi

# Init for root user
cd /root
sudo cp /home/root/.bashrc /home/root/.bashrc_preconda    
sudo -u root cp /home/root/.bashrc /home/root/.zshrc_preconda      
sudo -u root /usr/local/$CHOSEN/bin/conda init --system zsh    
sudo -u root /usr/local/$CHOSEN/bin/conda init --system bash 

# Init for other users
cd /home
for dir in */; do  
    export user=$(basename $dir)
    if id "$user" >/dev/null 2>&1; then # user exists
	if [[ "$user" != "root" ]]; then
	bashrc="/home/$user/.bashrc"
	if [[ -e $bashrc ]]; then
	    cmd='sudo  -u '$user' cp /home/'$user'/.bashrc /home/'$user'/.bashrc_preconda     ; '
	    cmd+='sudo -u '$user' cp /home/'$user'/.bashrc /home/'$user'/.zshrc_preconda      ; '
            cmd+='sudo -u '$user' /usr/local/'$CHOSEN'/bin/conda init --system zsh       ; '
            cmd+='sudo -u '$user' /usr/local/'$CHOSEN'/bin/conda init --system bash      ; '
	    cmd+='sudo -u '$user' /usr/local/'$CHOSEN'/bin/conda config --add envs_dirs /usr/local/'$CHOSEN'/envs ; '
	    cmd+='sudo -u '$user' /usr/local/'$CHOSEN'/bin/conda config --add pkgs_dirs /usr/local/'$CHOSEN'/pkgs ; '
	    cmd+='sudo chmod -R a+rw /usr/local/'$CHOSEN'/envs                             ; '
	    cmd+='sudo chmod -R a+rw /usr/local/'$CHOSEN'/pkgs '
	    echo "$cmd"
	    eval "$cmd"
	    fi
	fi
    fi
done

