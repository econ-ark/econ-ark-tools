#!/bin/bash

pathToScript=$(dirname `realpath "$0"`)
cloneScript="/tmp/rclone-to-Google-Drive_Last-ISO-Made.sh"

# pathToScript=/home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/VirtualBox/ISO-maker
cd "$pathToScript"

./make-MIN-ISO.sh
./make-MAX-ISO.sh
