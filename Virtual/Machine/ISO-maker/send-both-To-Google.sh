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

pathToScript=$(dirname `realpath "$0"`)

if [[ ! -e /root/.config/rclone/rclone.conf ]]; then
    echo 'For this script to work, /root/.config/rclone/rclone.conf must exist'
    echo 'and be configured with the right tokens for login and authentication'
    echo 'to the target Google Drive account.'
    echo ''
    echo 'An example rclone.conf file that links to the econ-ark@jhuecon.org drive is at'
    echo ''
    echo '/home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target/root/.config/rclone/rcloneconf.zip'
    echo ''
    echo 'which can be unzipped using the econ-ark@jhuecon.org login password:'
    echo ''
    echo 'sudo mkdir -p /root/.config/rclone ; sudo unzip /home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target/root/.config/rclone/rcloneconf.zip -d /root/.config/rclone '
    echo ''
    echo 'Then run again'
    exit
fi

echo ''
echo "/tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh:"
[[ -e /tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh ]] && sudo /tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh

echo ''
echo "/tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh:"
[[ -e /tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh ]] && sudo /tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh
