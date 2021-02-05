#!/bin/bash

pathToScript=$(dirname `realpath "$0"`)

if [[ ! -e /root/.config/rclone/rclone.conf ]]; then
    echo 'For this script to work, /root/.config/rclone/rclone.conf must exist'
    echo 'and be configured with the right tokens for login and authentication'
    echo 'to the target Google Drive account.'
    echo ''
    echo 'An example rclone.conf file that links to the econ-ark@jhuecon.org drive is at'
    echo ''
    echo '/var/local/root/.config/rcloneconf.zip'
    echo ''
    echo 'which can be unzipped using the econ-ark@jhuecon.org login password:'
    echo ''
    echo 'sudo mkdir -p /root/.config/rclone ; cd /var/local/root/.config/rclone ; sudo unzip /var/local/root/.config/rclone/rcloneconf.zip'
    echo ''
    echo 'then '
    echo ''
    echo 'sudo cp /var/local/root/.config/rclone/rclone.conf /root/.config/rclone'
    echo ''
    sleep 10
    exit
fi

echo ''
echo "/tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh:"
[[ -e /tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh ]] && sudo /tmp/rclone-to-Google-Drive_Last-ISO-Made-MIN.sh

echo ''
echo "/tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh:"
[[ -e /tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh ]] && sudo /tmp/rclone-to-Google-Drive_Last-ISO-Made-MAX.sh
