#!/bin/bash

pathToScript=$(dirname `realpath "$0"`)

cd "$pathToScript"

./make-MIN-ISO.sh
./make-MAX-ISO.sh
