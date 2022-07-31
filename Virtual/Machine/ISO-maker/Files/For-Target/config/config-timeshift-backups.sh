#!/bin/bash
# timeshift makes automated backups

partition_containing_sys="$(df -h / | tail -1 | cut -d ' ' -f1)"
uuid_of_root_partition="$(sudo blkid | grep UUID= | grep "$partition_containing_sys" | cut -d ' ' -f2)"
sed_code="s|partition_containing_sys|"$uuid_of_root_partition"|g"

sed -e "$sed_code" /var/local/sys_root_dir/etc/timeshift/timeshift.json > /etc/timeshift.json


