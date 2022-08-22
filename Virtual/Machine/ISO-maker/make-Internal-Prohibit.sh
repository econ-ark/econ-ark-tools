#!/bin/bash

pathToScript=$(dirname `realpath "$0"`)

# pathToScript=/home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker
cd "$pathToScript"

echo '' ; echo ''
echo 'Making ISO allowing install on internal device'
cmd="sudo ./create-unattended-iso_Econ-ARK-by-size.sh Internal-Prohibit"
echo "$cmd"
eval "$cmd"

echo '' ; echo ''

