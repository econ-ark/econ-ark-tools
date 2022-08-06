#!/bin/bash
# timeshift makes automated backups

# If it isn't installed yet, install it
[[ "$(which timeshift)" == "" ]] && sudo /var/local/installers/install-timeshift.sh

# If there's an existing config file, preserve it
[[ -e /etc/timeshift.json ]] && sudo cp /var/local/sys_root_dir/etc/timeshift.json /etc/timeshift_orig.json

# Modify the default config
sudo rpl  '"schedule_hourly" : "false",' '"schedule_hourly" : "true",' /etc/timeshift.json
sudo rpl  '"count_monthly" : "2",'       '"count_monthly" : "6",'      /etc/timeshift.json



