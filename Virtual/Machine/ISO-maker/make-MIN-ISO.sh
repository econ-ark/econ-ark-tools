#!/bin/bash

pathToScript=$(dirname `realpath "$0"`)
cloneScript="/tmp/rclone-to-Google-Drive_Last-ISO-Made.sh"

# pathToScript=/home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker
cd "$pathToScript"
echo '' ; echo ''
echo 'Making ISO for MIN install'
cmd="sudo ./create-unattended-iso_Econ-ARK-by-size.sh MIN"
echo "$cmd"
eval "$cmd"

echo '' ; echo ''


