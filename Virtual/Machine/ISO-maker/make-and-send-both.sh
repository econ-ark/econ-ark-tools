#!/bin/bash

pathToScript=$(dirname `realpath "$0"`)
cd "$pathToScript"

./make-Both-MIN-and-MAX-ISOs.sh
./send-both-To-Google.sh

