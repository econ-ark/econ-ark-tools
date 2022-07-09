#!/bin/bash

if [[ "$#" -ne 0 ]]; then
    echo 'debug-toggle takes no arguments; it simply switches the state of the verbosity flag '
    exit
fi

if [[ -e /var/local/status/verbose ]]; then
    echo 'verbose debugging mode was turned on; turning off'
    rm -Rf /var/local/status/verbose
else
    echo 'verbose debugging mode was turned off; turning on'
    mkdir -p /var/local/status/verbose
fi
