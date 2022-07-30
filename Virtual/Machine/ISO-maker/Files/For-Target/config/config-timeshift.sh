#!/bin/bash
# timeshift makes automated backups

partition_containing_sys="$(df -h / | tail -1 | cut -d ' ' -f1)"
sed_code="s|partition_containing_sys|"$partition_containing_sys

sed -e "$sed_code" /var/local/sys_root_dir/etc/timeshift/timeshift.json > /etc/timeshift.json


