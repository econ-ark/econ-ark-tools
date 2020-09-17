#!/bin/bash

if [ "$TERM" == "dumb" ]; then
    echo ''
    echo 'This script should be run from a smart terminal.'
    echo 'But $TERM='"$TERM"' probably because running in emacs shell'
    echo ''
    echo 'In emacs:'
    echo '    M-x "'"term"'" willl launch a smart terminal'
    echo '    C-x o will switch to the terminal buffer'
    echo '    C-c o will switch back out of the terminal buffer'
    echo ''
    exit 1
fi

for f in docker docker-engine docker.io containerd runc; do
    sudo apt-get -y remove "$f"
done

mkdir -p installers

curl -fsSL https://get.docker.com -o installers/get-docker.sh
cd installers
sh get-docker.sh

sudo usermod -aG docker econ-ark
