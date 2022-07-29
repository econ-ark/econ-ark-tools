#!/bin/bash
# Run this if you installed the MIN version
# and want to upgrade to the MAX version

cd /var/local/status

if [[ ! -e ./Size-To-Make-Is-MIN ]]; then
    echo 'Size-To-Make is not currently MIN'
    exit
fi
    
sudo mv /var/local/status/Size-To-Make-Is-MIN /var/local/status/Size-To-Make-Is-MAX

sudo /var/local/tools/finish-with-log.sh

