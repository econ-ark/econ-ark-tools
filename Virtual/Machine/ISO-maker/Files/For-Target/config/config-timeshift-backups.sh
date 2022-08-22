#!/bin/bash
# timeshift makes automated backups

# If it isn't installed yet, install it
[[ "$(which timeshift)" == "" ]] && sudo /var/local/installers/install-timeshift.sh

# If there's an existing config file, preserve it
install_time="$(date +%Y%m%d%H%M)"
[[ -e /etc/timeshift/timeshift.json ]] && sudo mv /etc/timeshift/timeshift.json /etc/timeshift/timeshift_orig_$install_time.json
sudo cp /var/local/sys_root_dir/etc/timeshift/timeshift.json /etc/timeshift/timeshift.json

sys_UUID="$(sudo /var/local/tools/determine-sys-UUID.sh)"

# Modify the default config
sudo rpl  'partition_containing_sys' "$sys_UUID" /etc/timeshift/timeshift.json
sudo rpl  '"schedule_hourly" : "false",' '"schedule_hourly" : "true",' /etc/timeshift/timeshift.json
sudo rpl  '"count_monthly" : "2",'       '"count_monthly" : "6",'      /etc/timeshift/timeshift.json



