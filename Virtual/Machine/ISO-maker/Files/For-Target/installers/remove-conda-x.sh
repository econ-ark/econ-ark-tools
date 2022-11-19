#!/bin/bash

# Install either miniconda or anaconda

if [[ "$#" -ne 1 ]]; then
    echo 'usage: $0 [anaconda|miniconda]'
    exit
fi

# In case they used capitals
export CHOSEN=$(echo $1 | tr '[:upper:]' '[:lower:]')
# CHOSEN=miniconda
ANA='anaconda' && MIN='miniconda'

[[ "$CHOSEN" != "$ANA" ]] && [[ "$CHOSEN" != "$MIN" ]] && bad_syntax=true
[[ "$CHOSEN" == "" ]] && echo "CHOSEN has no value; aborting" && exit

if [[ "$bad_syntax" == true ]]; then
    echo 'usage: $0 [anaconda|miniconda]'
    exit
fi

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
