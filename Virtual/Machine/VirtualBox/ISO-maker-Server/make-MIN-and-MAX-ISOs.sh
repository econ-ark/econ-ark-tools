#!/bin/bash

pathToScript=$(dirname `realpath "$0"`)
# pathToScript=/home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/VirtualBox/ISO-maker-Server
cd "$pathToScript"
echo '' ; echo ''
echo 'Making ISO for MIN install'
sudo ./create-unattended-iso_Econ-ARK-by-size.sh MIN
sudo /tmp/rclone-To-Google-Drive_Last-ISO-Made.sh
echo '' ; echo ''

echo 'Making ISO for MAX install'
sudo ./create-unattended-iso_Econ-ARK-by-size.sh MAX 
sudo /tmp/rclone-To-Google-Drive_Last-ISO-Made.sh

