#!/bin/bash

pathToScript=$(dirname `realpath "$0"`)
# pathToScript=/home/econ-ark/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker
cd "$pathToScript"

./make-MIN-ISO.sh
./make-MAX-ISO.sh
