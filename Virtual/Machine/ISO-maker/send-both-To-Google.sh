#!/bin/bash

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
    echo 'then '
    echo ''
    echo 'sudo mv /home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/Files/For-Target/root/.config/rclone/rclone.conf /root/.config/rclone ; cd ~/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/'
    echo ''
    exit
fi

echo ''
echo "/tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh:"
[[ -e /tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh ]] && sudo /tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh

echo ''
echo "/tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh:"
[[ -e /tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh ]] && sudo /tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh
