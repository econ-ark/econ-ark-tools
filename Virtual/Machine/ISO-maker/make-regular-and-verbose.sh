#!/bin/bash

pathToScript=$(dirname `realpath "$0"`)
# pathToScript=/usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/

cd $pathToScript

mkdir -p /var/local/status/verbose
touch    /var/local/status/verbose/.gitkeep

git add . ; git commit -m 'Verbose on' ; git push

$pathToScript/make-Internal-Allow.sh
$pathToScript/make-Internal-Prohibit.sh

git add . ; git commit -m 'Verbose off' ; git push

$pathToScript/make-Internal-Allow.sh
$pathToScript/make-Internal-Prohibit.sh

