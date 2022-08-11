#!/bin/bash

pathToScript=$(dirname `realpath "$0"`)
# pathToScript=/usr/local/share/data/GitHub/econ-ark/econ-ark-tools/Virtual/Machine/ISO-maker/

cd $pathToScript

[[ -e /var/local/status/verbose ]] && mv /var/local/status/verbose /var/local/status/verbose_off

git add . ; git commit -m 'Verbose on' ; git push

$pathToScript/make-Internal-Allow.sh
$pathToScript/make-Internal-Prohibit.sh

if [[ -e /var/local/status/verbose ]]; then
    mv /var/local/status/verbose_off /var/local/status/verbose
else
    mkdir -p /var/local/status/verbose
    touch    /var/local/status/verbose/.gitkeep
fi


git add . ; git commit -m 'Verbose off' ; git push

$pathToScript/make-Internal-Allow.sh
$pathToScript/make-Internal-Prohibit.sh

